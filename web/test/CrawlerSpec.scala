package test

import org.specs2.mutable._
import dispatch._
import org.w3c.dom._

import play.api.test._
import play.api.test.Helpers._

import com.soran.Crawler

class CrawlerSpec extends Specification {

  "Dispatch" should {
    "read html in bugs" in {
      val bugsNewTrackURL = "http://music.bugs.co.kr/newest/track/total"

      val req = url(bugsNewTrackURL)
      val resp = Http(req OK as.String).option() 

      resp must beSome
    }

    "read html that contain <html>" in {
      val bugsNewTrackURL = "http://music.bugs.co.kr/newest/track/total"

      val req = url(bugsNewTrackURL)
      val resp = Http(req OK as.String).option() 

      resp must beSome[String].which { doc: String => 
        doc must contain("<html")
      }

    }
  }

  "Parser" should {
    "parse string into document" in {
      val document = Crawler.getDocument("<html><head><title>hello world</title></head></html>")

      document.getElementsByTagName("title").item(0).getTextContent() must contain("hello world")
    }

    "find text node from element id" in {
      val document = Crawler.getDocument("""
        <html>
          <head>
            <title>asdf</title>
          </head>
          <body>
            <div id="test">
              hello world
            </div>
          </body>
        </html>
      """)

      document.getElementById("test").getTextContent() must contain("hello")
    }

    "get value from input" in {
      val elem = Crawler.getDocument("<div><input type=\"hidden\" value=\"hello world\" /></div>")
      var textContent = ""

      textContent = elem.getElementsByTagName("div").item(0).getFirstChild().getAttributes().getNamedItem("value").getTextContent()

      textContent must contain("hello world")
    }
  }

  "Crawler" should {
    "getNewTrackBugsIds from page" in {
      Crawler.getNewTrackBugsIds().length must be_>(0)
    }

    "getBugsTrackInfo" in {
      val trackId = "2949141"
      Crawler.getBugsTrackInfo(trackId) must beSome[Map[Symbol, String]].which(_('music) === "bugs-" + trackId)
    }

  }

}