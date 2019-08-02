{:user
 {:dependencies [[cljfmt "0.6.3"]
                 [cider/cider-nrepl "0.21.1"]]
  :plugins [[lein-exec "0.2.0"]
            [lein-project-clean  "0.1.5"]
            [jonase/eastwood  "0.2.4"]
            [http-kit/lein-template  "1.0.0-SNAPSHOT"]
            [com.jakemccrary/lein-test-refresh "0.22.0"]
            [com.palletops/uberimage  "0.4.1"]
            [lein-git-deps "0.0.1-SNAPSHOT"]]
  :repl-options  {:init  (require 'cljfmt.core) }}}
