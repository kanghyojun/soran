package controllers

import play.api._
import play.api.mvc._
import com.mintpresso._

case class SoranMusic(affogatoPoint: Point, count: Long)
object Profile extends Controller {
  val supportServiceNames: List[String] = List[String]("bugs", "naverMusic")
  def index(serviceName: String, userName: String) = Action {
    val affo: Affogato = new Affogato("cc64f8ee51c8420172a907baa81285ae", 13)
    val uIdentifier = "%s@%s".format(userName, serviceName)

    affo.get(_type="user", identifier=uIdentifier).map { p => 
      val listnedMusics = affo.get(
        None, "user", uIdentifier, "listen", 
        None, "music", "?").map { edgs =>

        val musicIdWithPlayCount: Map[Long, Long] = edgs.groupBy(_._object.id).mapValues(_.length)
        val musicLists: Iterable[SoranMusic] = for {
          (k, v) <- musicIdWithPlayCount
          p <- affo.get(k)
        } yield SoranMusic(p, v)

        musicLists
      }.getOrElse {
        Iterable[SoranMusic]()
      }

      Ok(views.html.profile(userName, listnedMusics))
    }.getOrElse {
      NotFound("Sorry")
    }
  }
}