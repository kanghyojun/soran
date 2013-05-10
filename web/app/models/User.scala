package models

import com.mintpresso._

object User extends SoranModel {

  def findByIdentifier(identifier: String): Option[Point] = {
    affogato.get(_type="user", identifier=identifier).as[Option[Point]]
  }

}
