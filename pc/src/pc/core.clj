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

(deftest pair-combinator
  (testing "That this works to parse..."
    (let [tag-opener (pair (match-literal "<") identifier)]
      (is (= {:ok ["/>" [[] "my-first-element"]]}
             (tag-opener "<my-first-element/>")))
      (is (= {:err "oops"}
             (tag-opener "oops")))
      (is (= {:err "!oops"}
             (tag-opener "!oops")))
      )))

(defn parser-map [parser map-fn]
  (fn [input]
    (let [r (parser input)]
      (if (:err r)
        (err (:err r))
        {:ok [(-> r :ok first) (apply  map-fn (-> r :ok second))]}))))

(defn left [parser1 parser2]
  (parser-map (pair parser1 parser2)
              (fn [l _] l)))

(defn right [parser1 parser2]
  (parser-map (pair parser1 parser2)
              (fn [_ r] r)))

(deftest right-combinator
  (testing "That this works to parse..."
    (let [tag-opener (right (match-literal "<") identifier)]
      (is (= {:ok ["/>" "my-first-element"]}
             (tag-opener "<my-first-element/>")))
      (is (= {:err "oops"}
             (tag-opener "oops")))
      (is (= {:err "!oops"}
             (tag-opener "!oops")))
      )))

(defn one-or-more [parser]
  ;; The helper function for recursion
  (fn [top-input]
    (let [helper-fn
          (fn [input {:keys [results]}]
            ;; Our forced one results
            (if (= 0 (count results))
              (let [parsed (parser input)
                    [next-input first-item] (:ok parsed)]
                (if (:err parsed)
                  (err input)
                  (recur next-input {:results (conj results first-item)})))
              ;; Our recursion branch
              (let [parsed (parser input)
                    [next-input next-item] (:ok parsed)]
                (if (:err parsed)
                  {:input input :results results}
                  (recur next-input {:results (conj results next-item)})))))]
      (let [final-result (helper-fn top-input {:input "" :results []})]
        {:ok [(:input final-result) (:results final-result)]}))))

(defn foo []
  (let [parser (one-or-more (match-literal "ha"))]
    (parser "hahaha")))

(deftest one-or-more-combinator
  (testing "One or more works"
    (let [parser (one-or-more (match-literal "ha"))]
      (is (= {:ok ["" [[] [] []]]}
             (parser "hahaha"))))))

;; Leaving off at about 50% (one-or-more)

(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  (println "Hello, World!"))
