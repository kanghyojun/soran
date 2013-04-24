import sbt._
import Keys._
import play.Project._

object ApplicationBuild extends Build {

  val appName         = "soran"
  val appVersion      = "1.0-SNAPSHOT"

  val appDependencies = Seq(
    // Add your project dependencies here,
    jdbc,
    anorm,
    "mintpresso" % "mintpresso_2.10" % "0.1.7",
    "net.databinder.dispatch" % "dispatch-core_2.10" % "0.9.5",
    "nu.validator.htmlparser" % "htmlparser" % "1.4"
  )


  val main = play.Project(appName, appVersion, appDependencies).settings(
    // Add your own project settings here      
    resolvers += "Local Maven Repository" at "file://"+Path.userHome.absolutePath+"/.m2/repository"
  )
}