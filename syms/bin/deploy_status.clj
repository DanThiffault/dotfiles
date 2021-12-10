#!/bin/sh
#_(

   #_DEPS is same format as deps.edn. Multiline is okay.
   DEPS='
   {:deps {org.clojure/tools.cli {:mvn/version "0.4.2"}
           com.cognitect.aws/api       {:mvn/version "0.8.408"}
           com.cognitect.aws/endpoints {:mvn/version "1.1.11.705"}
           com.cognitect.aws/codepipeline {:mvn/version "773.2.570.0", :aws/serviceFullName "AWS CodePipeline"}
           clojure.java-time  {:mvn/version "0.3.2"}
           cljc.java-time  {:mvn/version  "0.1.7"}
           clj-jgit  {:mvn/version  "1.0.0-beta3"}}}
   '

   #_You can put other options here
   OPTS='
   -J-Xms256m -J-Xmx256m -J-client
   '

#exec clojure $OPTS -Sdeps "$DEPS" "$0" "$@"
exec clj -Sdeps "$DEPS"

)
(def cli-options
  ;; An option with a required argument
  [["-p" "--port PORT" "Port number"
    :default 80
    :parse-fn #(Integer/parseInt %)
    :validate [#(< 0 % 0x10000) "Must be a number between 0 and 65536"]]
   ;; A non-idempotent option (:default is applied first)
   ["-v" nil "Verbosity level"
    :id :verbosity
    :default 0
    :update-fn inc]
   ;; A boolean option defaulting to nil
   ["-h" "--help"]])

;(println (parse-opts *command-line-args* cli-options))

(require '[clojure.tools.cli :refer [parse-opts]])
(require '[cognitect.aws.client.api :as aws])
(require '[cognitect.aws.client.api.async :as aws.async])
(require '[clojure.core.async :as a])

(require '[clj-jgit.porcelain :as git])
(require '[java-time :as jt])

(def codepipeline (aws/client {:api :codepipeline}))

(def c (aws/invoke codepipeline {:op :ListPipelineExecutions :request {:pipelineName "tf2-production-lello"}}))

(comment
  (= (-> c :pipelineExecutionSummaries first :sourceRevisions first :revisionId) "90cbba8c45dbbfc8ff4aaccd4f4cce5a28af6ce4"))


(comment
  (def repo (git/load-repo  "/home/dan/dev/lello/"))
  (def commit (first (sequence (filter #(= "Dan Thiffault" (-> % :author :name))) (git/git-log repo :max-count 10))))


  )

