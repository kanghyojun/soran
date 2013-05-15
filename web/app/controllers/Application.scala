package controllers

import play.api._
import play.api.mvc._
import play.api.i18n.Messages 

object Application extends Controller {
  
  def index = Action {
    Ok(views.html.index(Messages("soran.welcome")))
  }

  def help = Action {
    Ok(views.html.help())
  }
}
