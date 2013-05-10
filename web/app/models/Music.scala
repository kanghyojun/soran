package models

import com.mintpresso._

case class Music(affogatoPoint: Point, count: Long)

object Music extends SoranModel {

  def findByIdentifier(identifier: String): Iterable[Music] = {
    affogato.get(
      None, "user", identifier, "listen", 
      None, "music", "?").map { edgs =>

      val musicIdWithPlayCount: Map[Long, Long] = edgs.groupBy(_._object.id).mapValues(_.length)
      val musicLists: Iterable[Music] = for {
        (k, v) <- musicIdWithPlayCount
        p <- affogato.get(k)
      } yield Music(p, v)

      musicLists
    }.getOrElse {
      Iterable[Music]()
    }
  }

}
