(ns pc.core-test
  (:require [clojure.test :refer [deftest testing is]]
            [pc.core :refer :all]))

(deftest a-test
  (testing "I pass."
    (is (= 1 1))))
