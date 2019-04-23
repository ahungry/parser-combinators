(ns pc.core
  (:require
   [clojure.spec.alpha :as s]
   [clojure.spec.gen.alpha :as gen]
   [clojure.spec.test.alpha :as stest]
   [clojure.repl :refer :all]
   [clojure.test :as t :refer [deftest testing is run-tests]])
  (:gen-class))

(defrecord Attribute [id value])

;; string, attribute[], element[]
(defrecord Element [name attributes children])

(defn ok [s] [{:ok s} true])
(defn err [s] [{:err s} false])

(defn the-letter-a [s]
  (or (some->> (re-find #"a(.*)" s) last ok)
      (err s)))

(defn match-literal [r]
  (fn [s]
    (or (some->> (re-find (re-pattern (str r "(.*)")) s) last ok)
        (err s))))

(deftest match-literal-test
  (testing "We can match literals."
    (let [parse-joe (match-literal "Hello Joe!")]
      (is (= true (second (parse-joe "Hello Joe!"))))
      (is (= {:ok " Hello Robert!"} (first (parse-joe "Hello Joe! Hello Robert!"))))
      (is (= {:err "Hello Mike!"} (first (parse-joe "Hello Mike!"))))
      )))

(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  (println "Hello, World!"))
