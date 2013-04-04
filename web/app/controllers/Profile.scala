package controllers

import play.api._
import play.api.mvc._
import com.mintpresso._

object Profile extends Controller {
  
  def index(serviceName: String, userName: String) = Action {
    val affo: Affogato = new Affogato("cc64f8ee51c8420172a907baa81285ae", 13)
    affo.get(_type="user", identifier=userName + "@" + serviceName).map { p => 
      Ok(views.html.profile(userName))
    }.getOrElse {
      NotFound("Sorry")
    }
  }
}