package models

import com.mintpresso._

case class Music(affogatoPoint: Point, count: Long)

object Music extends SoranModel {

  def findUserByMusicIdentifier(identifier: String) = affogato.get(None, "user", "?", "listen", None, "music", identifier, getInnerPoints=true)

  def findAllByIdentifier(identifier: String): Map[Point, List[Point]] = {
    val respond = affogato.get(None, "user", identifier, "listen", 
                               None, "music", "?")
    respond match {
      case Right(d) => d.groupBy(_.subject).mapValues(_.map(_._object))
      case Left(l) => Map[Point, List[Point]]()
    }

  }

  def findByIdentifier(identifier: String): List[Music] = {
    val respond = affogato.get(None, "user", identifier, "listen", 
                               None, "music", "?")
    var result: List[Music] = List[Music]()
    respond match {
      case Right(d) => {
        for((k, v) <- d.groupBy(_._object.id)) {
          result = Music(v.head._object, v.length) :: result
        }
        result
      }
      case Left(l) => println(l.message);List[Music]()
    }
  }

}
