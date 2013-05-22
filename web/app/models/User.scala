package models

import com.mintpresso._

object User extends SoranModel {

  def findByIdentifier(identifier: String): Option[Point] = {
    affogato.get(_type="user", identifier=identifier).as[Option[Point]]
  }

  def findNeighborByIdentifier(iden: String): List[Point] = {
    val listened: List[Music] = Music.findByIdentifier(iden).toList
    val top10Music: List[Music] = listened.sortWith((m1: Music, m2: Music) => m1.count > m2.count)
    var userIds: List[Long] = List[Long]()
    var me: Option[Point] = findByIdentifier(iden)
    var a: List[(String, String)] = List[(String, String)]()

    for(u <- me;
        m <- top10Music;
        edges <- Music.findUserByMusicIdentifier(m.affogatoPoint.identifier)
    ) {
      userIds = userIds ++ edges.filter(_.subject.id != u.id).map(_.subject.id)
    }

    (for {
      i: Long <- userIds.toSet
      p <- affogato.get(i)
    } yield p).toList
  }
}
