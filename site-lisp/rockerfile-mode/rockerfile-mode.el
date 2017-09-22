;;; dockerfile-mode.el --- Major mode for editing Docker's Dockerfiles

;; Copyright (c) 2017 Dr. Stefan Kaes
;;
;; Licensed under the Apache License, Version 2.0 (the "License"); you may not
;; use this file except in compliance with the License. You may obtain a copy of
;; the License at
;;
;; http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
;; WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
;; License for the specific language governing permissions and limitations under
;; the License.

;;; Code:

(require 'sh-script)
(require 'rx)
(require 'dockerfile-mode)

(defvar rockerfile-font-lock-keywords
  `(,(cons (rx (or line-start "onbuild ")
               (group (or "from" "maintainer" "run" "cmd" "expose" "env" "arg"
                          "add" "copy" "entrypoint" "volume" "user" "workdir" "onbuild"
                          "label" "stopsignal" "shell" "healthcheck"
                          "tag" "push" "attach" "import" "export" "mount"))
               word-boundary)
           font-lock-keyword-face)
    ,@(sh-font-lock-keywords)
    ,@(sh-font-lock-keywords-2)
    ,@(sh-font-lock-keywords-1))
  "Default keywords for `rockerfile mode'.")

(define-derived-mode rockerfile-mode dockerfile-mode "Rockerfile"
  "A major mode to edit Rockerfiles.
\\{rockerfile-mode-map}
"
  (set (make-local-variable 'font-lock-defaults)
       '(rockerfile-font-lock-keywords nil t)))

;;;###autoload
(add-to-list 'auto-mode-alist '("Rockerfile.*\\'" . rockerfile-mode))

(provide 'rockerfile-mode)

;;; dockerfile-mode.el ends here
