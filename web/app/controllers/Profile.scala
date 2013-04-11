package controllers

import play.api._
import play.api.mvc._

import models._

object Profile extends Controller {
  val supportServiceNames: List[String] = List[String]("bugs", "naverMusic")
  def index(serviceName: String, userName: String) = Action {
    val uIdentifier = "%s@%s".format(userName, serviceName)

    User.findByIdentifier(uIdentifier).map { p =>  
      val listnedMusics: Iterable[Music] = Music.findByIdentifier(uIdentifier)

      Ok(views.html.profile(userName, listnedMusics))
    }.getOrElse {
      NotFound("Sorry")
    }
  }
}