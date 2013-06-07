package models

import com.mintpresso._

object User extends SoranModel {

  def findByIdentifier(identifier: String): Either[Respond, Point] = {
    return affogato.get(_type="user", identifier=identifier)
  } 

  def findNeighborByIdentifier(iden: String): Map[Point, List[Music]] = {
    val listened: List[Music] = Music.findByIdentifier(iden)
    val top10Music: List[Music] = listened.sortWith((m1: Music, m2: Music) => m1.count > m2.count).slice(0, 10)
    var people: List[(Point, Music)] = List[(Point, Music)]()

    for(m <- top10Music;
        edges <- Music.findUserByMusicIdentifier(m.affogatoPoint.identifier).right
    ) {
      people = people ++ edges.filter(_.subject.identifier != iden).map { e=>
        (e.subject, m)
      }
    }

    return people.groupBy(_._1).mapValues(_.map(_._2))
  }

}
