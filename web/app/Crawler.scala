package com.soran

import scala.language.implicitConversions

import dispatch._
import org.w3c.dom.{Element, Node, NodeList, NamedNodeMap}


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

  def getBugsTrackInfo(id: String): Option[String] = {
    val bugsURL = "http://music.bugs.co.kr/player/track/%s".format(id)

    Http(url(bugsURL) OK as.String).option().map { data =>
        val json = scala.util.parsing.json.JSON.parseFull(data)
        json.map { mapData =>
          try {
            var bugsTrack = mapData.asInstanceOf[Map[String, Any]]("track").asInstanceOf[Map[String, Any]]
            Some(bugsTrack("trackId").asInstanceOf[Map[String, Double]]("id").toLong.toString)
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