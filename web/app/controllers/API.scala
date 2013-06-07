package controllers

import play.api._
import play.api.mvc._
import play.api.libs.iteratee._
import play.api.libs.json._

import models._
import com.mintpresso.Point

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
  def musics(identifier: String) = Action {
    val musics: List[Music] = Music.findByIdentifier(identifier)
    JsonOk(200, "", Json.toJson(musics))
  }

  def neighbor(identifier: String) = Action {
    val neighbor: Map[Point, List[Music]] = User.findNeighborByIdentifier(identifier)
    
    JsonOk(200, "", Json.toJson(neighbor))
  }
}
