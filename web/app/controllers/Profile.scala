package controllers

import play.api._
import play.api.mvc._

object Profile extends Controller {
  
  def index(url: String) = Action {
    Ok(views.html.profile(url))
  }
}