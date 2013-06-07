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
    "com.mintpresso" %% "mintpresso" % "0.2.2",
    "net.databinder.dispatch" % "dispatch-core_2.10" % "0.10.1",
    "nu.validator.htmlparser" % "htmlparser" % "1.4"
  )


  val main = play.Project(appName, appVersion, appDependencies).settings(
    // Add your own project settings here      
    resolvers += "Local Maven Repository" at "file://"+Path.userHome.absolutePath+"/.m2/repository",
    coffeescriptOptions := Seq("native", "/usr/local/bin/coffee -p")
  )
}
