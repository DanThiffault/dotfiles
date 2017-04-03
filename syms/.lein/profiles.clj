{:user
 {:dependencies [[cljfmt "0.5.1"]]
  :plugins [
            [lein-exec "0.2.0"]
            [http-kit/lein-template  "1.0.0-SNAPSHOT"]
            [com.jakemccrary/lein-test-refresh "0.18.1"]
            [com.palletops/uberimage  "0.4.1"]
            [lein-git-deps "0.0.1-SNAPSHOT"]]
  :repl-options  {:init  (require 'cljfmt.core)}}}
