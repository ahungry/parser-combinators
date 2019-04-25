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
    (if (or (= 0 (count s))
            (> (count r) (count s)))
      (err s)
      (let [_first (subs s 0 (count r))
            rest (subs s (count r))]
        (if (= 0 (clojure.string/index-of s r))
          {:ok [rest []]}
          (err s))))))

(deftest match-literal-test
  (testing "We can match literals."
    (let [parse-joe (match-literal "Hello Joe!")]
      (is (= {:ok ["" []]} (parse-joe "Hello Joe!")))
      (is (= {:ok ["\nHello Robert!" []]} (parse-joe "Hello Joe!\nHello Robert!")))
      (is (= {:err "Hello Mike!"} (parse-joe "Hello Mike!")))
      )))

;; DOTALL mode https://nakkaya.com/2009/10/25/regular-expressions-in-clojure/
(defn identifier [s]
  (let [maybe (re-find #"^(?s)([A-Za-z0-9-]+)(.*)" s)]
    (if (not maybe)
      (err s)
      (some->> maybe ok))))

(deftest identifier-test
  (testing "We can match identifier"
    (is (= {:ok ["" "i-am-an-identifier"]}
           (identifier "i-am-an-identifier")))
    (is (= {:ok ["\nentirely an identifier" "not"]}
           (identifier "not\nentirely an identifier")))
    (is (= {:ok [" entirely \nan identifier" "not"]}
           (identifier "not entirely \nan identifier")))
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

(defn zero-or-more [parser]
  ;; The helper function for recursion
  (fn [top-input]
    (let [helper-fn
          (fn [input {:keys [results]}]
            ;; Our recursion branch
            (let [parsed (parser input)
                  [next-input next-item] (:ok parsed)]
              (if (:err parsed)
                {:input input :results results}
                (recur next-input {:results (conj results next-item)}))))]
      (let [final-result (helper-fn top-input {:input "" :results []})]
        (if (:err final-result)
          final-result
          {:ok [(:input final-result) (:results final-result)]})))))

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
        (if (:err final-result)
          final-result
          {:ok [(:input final-result) (:results final-result)]})))))

(deftest one-or-more-combinator
  (testing "One or more works"
    (let [parser (one-or-more (match-literal "ha"))]
      (is (= {:ok ["" [[] [] []]]}
             (parser "hahaha")))
      (is (= {:err "ahah"}
             (parser "ahah")))
      (is (= {:err ""}
             (parser "")))
      )))

(deftest zero-or-more-combinator
  (testing "One or more works"
    (let [parser (zero-or-more (match-literal "ha"))]
      (is (= {:ok ["" [[] [] []]]}
             (parser "hahaha")))
      (is (= {:ok ["ahah" []]}
             (parser "ahah")))
      (is (= {:ok ["" []]}
             (parser "")))
      )))

(defn any-char [s]
  (if (= 0 (count s)) {:ok [" "]}
      {:ok [(subs s (min 1 (count s)))
            (subs s 0 (min 1 (count s)))]}))

(defn pred [parser predicate]
  (fn [input]
    (let [parsed (parser input)
          [next-input value] (:ok parsed)]
      (if (:err parsed)
        (err input)
        (if (predicate value)
          {:ok [next-input value]}
          {:err input})))))

(deftest pred-test
  (testing "That the predicate works"
    (let [parser (pred any-char
                       (fn [c]
                         (= c "o")))]
      (is (= {:ok ["mg" "o"]}
             (parser "omg")))
      (is (= {:err "lol"}
             (parser "lol"))))))

(defn whitespace-char [] (pred any-char (fn [c] (re-find #"\s" (str c)))))
(defn space-1 [] (one-or-more (whitespace-char)))
(defn space-0 [] (zero-or-more (whitespace-char)))
(defn quoted-string [s]
  ((parser-map
    (right (match-literal "\"")
           (left (zero-or-more (pred any-char (fn [c] (not (= "\"" c)))))
                 (match-literal "\"")))
    (fn [& args]
      (clojure.string/join args))) s))

(deftest quoted-string-test
  (testing "That quoted string parsing works."
    (is (= {:ok ["" "Hello Joe!"]}
           (quoted-string "\"Hello Joe!\"")))))

;; TODO: The attribute parser stuff isn't working atm
(defn attribute-pair []
  (pair identifier (right (match-literal "=") quoted-string)))

(defn ap-test []
  ((attribute-pair) "foo=\"bar\""))

(defn attributes []
  (zero-or-more (right (space-1) (attribute-pair))))

(defn attr-str []
  " one=\"1\" two=\"2\"")

(defn foo []
  ((attributes) (attr-str)))

;; TODO: Why do I have to have leading string??
(deftest attributes-test
  (testing "That we can parse attributes"
    (is (= {:ok ["" [["one" "1"]
                     ["two" "2"]]]}
           ((attributes) " one=\"1\" two=\"2\""))))
  )

(defn element-start []
  (right (match-literal "<")
         (pair identifier (attributes))))

(defn single-element []
  (parser-map
   (left (element-start) (match-literal "/>"))
   (fn [name attributes]
     (->Element name attributes []))))

(deftest single-element-test
  (testing "That we can do a single element"
    (is (= {:ok ["" (->Element "div" [["class" "float"]] [])]}
           ((single-element) "<div class=\"float\"/>")))))

(defn open-element []
  (parser-map
   (left (element-start) (match-literal ">"))
   (fn [name attributes]
     (->Element name attributes []))))

(defn either [parser1 parser2]
  (fn [input]
    (let [parsed1 (parser1 input)]
      (if (:ok parsed1)
        parsed1
        (let [parsed2 (parser2 input)]
          (if (:ok parsed2)
            parsed2
            (err input)))))))

(defn whitespace-wrap [parser]
  (right (space-0)
         (left parser (space-0))))

(declare parent-element)

(defn element []
  (whitespace-wrap
   (either (single-element) (parent-element))))

(defn close-element [expected-name]
  (pred
   (right (match-literal "</")
          (left identifier (match-literal ">")))
   (fn [name]
     (= name expected-name))))

(defn and-then [parser f]
  (fn [input]
    (let [parsed (parser input)
          [next-input result] (:ok parsed)]
      (if (:err parsed)
        (err parsed)
        ((f result) next-input)))))

(defn parent-element []
  (and-then
   (open-element)
   (fn [el]
     (parser-map
      (left (zero-or-more (element))
            (close-element (:name el)))
      (fn [& children]
        (map->Element (conj el {:children (into [] children)}))))
     )))

(defn blub []
  (let [doc (slurp "doc.xml")
        parsed ((element) doc)]
    parsed))

(def expected-doc-tree
  {:ok
   [""
    {:name "top",
     :attributes [["label" "Top"]],
     :children
     [{:name "semi-bottom",
       :attributes [["label" "Bottom"]],
       :children []}
      {:name "middle",
       :attributes [],
       :children
       [{:name "bottom",
         :attributes [["label" "Another bottom"]],
         :children []}]}]}]})

(deftest xml-parser
  (testing "That we can parse xml"
    (let [doc (slurp "doc.xml")
          parsed ((element) doc)
          deep-path (-> parsed :ok (get 1) :children (get 1) :children (get 0) :attributes (get 0) (get 1))]
      (is (= deep-path "Another bottom"))))
  )
;; (deftest xml-parser []
;;   (testing "That we can parse some fake xml"
;;     (let [doc (slurp "doc.xml")
;;           parsed ()]
;;       (is )
;;       )))

(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  (println "Hello, World!"))
