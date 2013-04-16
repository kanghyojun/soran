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

      for(i <- 0 to listTags.getLength()) { 
        val listRaw = listTags.item(i)
        /*
        val attr: NamedNodeMap = inputIsStream.getAttributes() 
        if(attr == null) throw new Exception("ul#%s > li > input dosen't have attribute at %s".format(ulId, bugsNewTrackURL))



        listOfIds = attr.getNamedItem("value").getTextContent() :: listOfIds
        */
        listOfIds = "123" :: listOfIds
      }

      listOfIds
    }.getOrElse {
      List[String]()
    }
  }
  
}