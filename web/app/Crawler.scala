package com.soran

import scala.concurrent.duration._
import scala.concurrent._
import scala.language.implicitConversions
import java.util.Date

import akka.actor.{Actor, Props, ActorSystem}
import akka.actor.Actor._
import dispatch._
import org.w3c.dom.{Element, Node, NodeList, NamedNodeMap}
import play.api.Logger

import com.mintpresso._


class CrawlerActor extends Actor {

  import CrawlerActor._

  val affogato = Affogato("240ff06dee7-f79f-423f-9684-0cedd2c13ef3", 240)
  var lastModifiedSince = new Date()
  var cached: List[String] = List[String]()


  def receive = {
    case Crawling() => {
      Logger.debug("Crawling Started at %s".format(new Date()))
      val n = Crawler.getNewTrackBugsIds()

      if(cached != n) {
        val added: List[String] = (n.toSet &~ cached.toSet).toList
        for (
          trackId <- added;
          data: Map[String, String] <- Crawler.getBugsTrackInfo(trackId)
          if data.isEmpty != true
        ) {
          val mintData =
            """
            {
              "artist": "%s",
              "artistId": "%s",
              "albumArtist": "%s",
              "albumTitle": "%s",
              "albumId": "%s",
              "title": "%s",
              "genre": "%s",
              "len": "%s",
              "releaseDate": "%s"
            }
            """.format(
            data("artist"),
            data("artistId").toString(),
            data("albumArtist"),
            data("albumTitle"),
            data("albumId").toString(),
            data("title"),
            data("genre"),
            data("len"),
            data("releaseDate")
          )
          try{
            val p = affogato.set(
              _type = "music",
              identifier = data("music"),
              data = mintData)
            p.map { rp =>
              Logger.debug("Point Identifier, " + rp.identifier)
            }
            if(p.isEmpty == true) Logger.debug("Affogato set failed. {identifier: %s, title: %s}".format(data("music"), data("title")))
          } catch {
            case e: Throwable => Logger.debug("mintdata - " + mintData)            
          }
        }

        lastModifiedSince = new Date()
        cached = n
      } else {
        Logger.debug("Not changed bugs track.") 
      }
    }
  }

}

object CrawlerActor {
  case class Crawling()

  val system = ActorSystem("CrawlerActor")
  val ref = system.actorOf(Props[CrawlerActor])
}



object Crawler {

  def getDocument(docInString: String): org.w3c.dom.Document = {
    val documentBuilder = new nu.validator.htmlparser.dom.HtmlDocumentBuilder()
    val document = documentBuilder.parse(new org.xml.sax.InputSource(new java.io.StringReader(docInString)))

    document.getDocumentElement().normalize() 

    return document
  }

  def getNewTrackBugsIds(): List[String] = {
    val bugsNewTrackURL = "http://music.bugs.co.kr/newest/track/total"
    val req = url(bugsNewTrackURL)
    Http(req OK as.String).option().map { doc =>
      val ulId = "idTrackList"
      val document = getDocument(doc)
      val idTrackList: Element = document.getElementById(ulId) 
      val listTags: NodeList = idTrackList.getElementsByTagName("li")
      var listOfIds: List[String] = List[String]()

      val listInput: NodeList = idTrackList.getElementsByTagName("input")
      for(i <- 0 to listInput.getLength() - 1) {
        val inputTag = listInput.item(i)
          val inputAttr = inputTag.getAttributes()

          if(inputAttr.getNamedItem("type").getTextContent() == "hidden" 
             && inputAttr.getNamedItem("name").getTextContent()=="_isStream") {
            listOfIds = inputAttr.getNamedItem("value").getTextContent() :: listOfIds
          }
      }

      listOfIds
    }.getOrElse {
      List[String]()
    }
  }

  def getBugsTrackInfo(id: String): Option[Map[String, String]] = {
    val bugsURL = "http://music.bugs.co.kr/player/track/%s".format(id)

    Http(url(bugsURL) OK as.String).option().map { data =>
        val json = scala.util.parsing.json.JSON.parseFull(data)
        json.map { mapData =>
          try {
            var bugsTrack = mapData.asInstanceOf[Map[String, Any]]("track").asInstanceOf[Map[String, Any]]
            val trackId = bugsTrack("trackId").asInstanceOf[Map[String, Double]]("id").toLong.toString 
            val trackIdentifier = "bugs-%s".format(trackId)
            val trackArtistName = bugsTrack("artist_nm").asInstanceOf[String]
            val trackArtistId = bugsTrack("artist_id").asInstanceOf[Double].toLong.toString
            val trackAlbumTitle = bugsTrack("album_title").asInstanceOf[String]
            val trackAlbumArtistName = bugsTrack("album_artist_nm").asInstanceOf[String]
            val trackAlbumId = bugsTrack("album_id").asInstanceOf[Double].toLong.toString
            val trackGenre = bugsTrack("genre_dtl").asInstanceOf[String]
            val trackLen = bugsTrack("len").asInstanceOf[String]
            val trackRelease = bugsTrack("release_ymd").asInstanceOf[String]
            val title = bugsTrack("track_title").asInstanceOf[String]

            val data: Map[String, String] = Map( 
              "music" -> trackIdentifier,
              "artist" -> trackArtistName,
              "artistId" -> trackArtistId,
              "albumArtist" -> trackAlbumArtistName,
              "albumTitle" -> trackAlbumTitle,
              "albumId" -> trackAlbumId,
              "title" -> title,
              "genre" -> trackGenre,
              "len" -> trackLen,
              "releaseDate" -> trackRelease
            )
            Some(data) 
          } catch {
            case e: Throwable => throw new Exception("Bugs Track information is not valid for soran. ==>> %s".format(data)) 
          }
        }.getOrElse {
          None
        }
    }.getOrElse {
      None
    }
  }
  
}