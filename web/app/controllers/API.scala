package controllers

import play.api._
import play.api.mvc._
import play.api.libs.iteratee._
import play.api.libs.json._

import models._
import com.mintpresso.{Point, Edge}

trait JSONRespone {
  implicit val bigIntWrites = new Writes[BigInt] {
    def writes(p: BigInt): JsValue = {
      JsNumber(p.toString.toLong)
    }
  }

  implicit val pointWrites = new Writes[Point] {
    def writes(p: Point): JsValue = {
      Json.obj(
        "id" -> p.id,
        "type" -> p._type,
        "identifier" -> p.identifier,
        "data" -> p.data,
        "createdAt" -> p.createdAt,
        "updatedAt" -> p.updatedAt,
        "referencedAt" -> p.referencedAt
      )
    }
  }

  implicit val musicWrites = new Writes[Music] {
    def writes(m: Music): JsValue = {
      Json.obj(
        "count" -> m.count,
        "point" -> m.affogatoPoint
      ) 
    }
  }

  implicit val pnmWrites = new Writes[Map[Point, List[Music]]] {
    def writes(m: Map[Point, List[Music]]): JsValue = {
      var l: List[JsValue] = List[JsValue]()
      for((k,v) <- m) {
        l = Json.obj("person" -> k, "musics" -> v) :: l
      }
      Json.toJson(l)
    }
  }

  implicit val edgeWrites = new Writes[Edge] {
    def writes(l: Edge): JsValue = {
      Json.obj(
        "subject" -> l.subject,
        "verb" -> l.verb,
        "object" -> l._object,
        "_url" -> l.url,
        "createdAt" -> l.createdAt
      )
    }
  }

  implicit val mWrites = new Writes[Map[Point, List[Point]]] {
    def writes(m: Map[Point, List[Point]]): JsValue = {
      var l: List[JsValue] = List[JsValue]()
      for((k, v) <- m) {
        l = Json.obj("person" -> k, "musics" -> v) :: l
      }
      Json.toJson(l)
    }
  }

  def JsonOk(code: Int, message: String, content: JsValue): Result = {
    val json = Json.stringify(Json.obj(
      "code" -> code,
      "message" -> message,
      "content" -> content
    )).getBytes("UTF8")

    SimpleResult(
      header = ResponseHeader(
        200,
        Map(
          "Content-Length" -> json.length.toString,
          "Content-Type" -> "text/plain; charset=UTF-8"
        )
      ),
      body = Enumerator[Array[Byte]](json)
    ) 
  }
}

object API extends Controller with JSONRespone {
  def musics(identifier: String, specific: Boolean) = Action {
    var json: JsValue = null
    if(specific) {
      println("specific true")
      val musics: Map[Point, List[Point]] = Music.findAllByIdentifier(identifier)
      json = Json.toJson(musics)
    } else {
      val musics: List[Music] = Music.findByIdentifier(identifier)
      json = Json.toJson(musics)
    }

    JsonOk(200, "", json)
  }

  def neighbor(identifier: String) = Action {
    val neighbor: Map[Point, List[Music]] = User.findNeighborByIdentifier(identifier)
    
    JsonOk(200, "", Json.toJson(neighbor))
  }

  def edge(identifier: String) = Action {
    val s = new SoranModel()
    s.affogato.get(
      None, "user", identifier, "listen",
      None, "music", "?", false) match {
      case Right(edges) => {
        JsonOk(200, "", Json.toJson(edges))
      }
      case Left(r) => JsonOk(r.code.toInt, r.message, JsString(""))
    }
  }

}
