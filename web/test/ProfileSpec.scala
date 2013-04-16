package test

import org.specs2.mutable._

import play.api.test._
import play.api.test.Helpers._
import play.api.i18n.Messages 


class ProfileSpec extends Specification {
  
  "Profile" should {
    
    "render the user profile page" in {
      running(FakeApplication()) {
        val profile = route(FakeRequest(GET, "/bugs/@/admire93")).get 
        contentAsString(profile) must contain("admire93")
      }
    }
  }
}