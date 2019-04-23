;; https://bodil.lol/parser-combinators/

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

(defn ok [ss]
  (let [ss (subvec ss 1)]
    (if (> (count ss ) 1)
      {:ok (reverse ss)}
      {:ok [(first ss) []]})
    ;; {:ok [(first ss) (or (second ss) true)]}
    ))

(defn err [s] {:err s})

(defn the-letter-a [s]
  (or (some->> (re-find #"a(.*)" s) last ok)
      (err s)))

(defn match-literal [r]
  (fn [s]
    (or (some->> (re-find (re-pattern (str "^" r "(.*)")) s) ok)
        (err s))))

(deftest match-literal-test
  (testing "We can match literals."
    (let [parse-joe (match-literal "Hello Joe!")]
      (is (= {:ok ["" []]} (parse-joe "Hello Joe!")))
      (is (= {:ok [" Hello Robert!" []]} (parse-joe "Hello Joe! Hello Robert!")))
      (is (= {:err "Hello Mike!"} (parse-joe "Hello Mike!")))
      )))

(defn identifier [s]
  (let [maybe (re-find #"^([A-Za-z0-9-]+)(.*)" s)]
    (if (not maybe)
      (err s)
      (some->> maybe ok))))

(deftest identifier-test
  (testing "We can match identifier"
    (is (= {:ok ["" "i-am-an-identifier"]}
           (identifier "i-am-an-identifier")))
    (is (= {:ok [" entirely an identifier" "not"]}
           (identifier "not entirely an identifier")))
    (is (= {:err "!not at all an identifier"}
           (identifier "!not at all an identifier")))
    ))

(defn pair [parser1 parser2]
  (fn [input]
    (let [r1 (parser1 input)
          r1-next (some-> r1 :ok first)
          r1-result (some-> r1 :ok second)]
      (if (not r1-next)
        (err (:err r1))
        (let [r2 (parser2 r1-next)
              final-input (some-> r2 :ok first)
              r2-result (some-> r2 :ok second)]
          (if (not final-input)
            (err (:err r2))
            {:ok [final-input [r1-result r2-result]]}))))))

(defn hmm []
  (let [tag-opener (pair (match-literal "<") identifier)]
    (tag-opener "<my-first-element/>")))

(deftest pair-combinator
  (testing "That this works to parse..."
    (let [tag-opener (pair (match-literal "<") identifier)]
      (is (= {:ok ["/>" [[] "my-first-element"]]}
             (tag-opener "<my-first-element/>"))))))

(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  (println "Hello, World!"))
