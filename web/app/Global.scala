import play.api.{GlobalSettings, Logger, Application}

import play.api.libs.concurrent._
import play.api.libs.concurrent.Execution.Implicits._

import scala.concurrent.duration._

import com.soran._
import com.soran.CrawlerActor._

object Global extends GlobalSettings {
  override def onStart(app: Application) {

   //60 minutes
   CrawlerActor.system.scheduler.schedule(0 seconds, 30 seconds, CrawlerActor.ref, Crawling())
  }  
}
