;; override some of steve's decisions
(setq-default line-spacing 0.2)
(global-set-key (kbd "M-+") 'default-text-scale-increase)
(global-set-key (kbd "M--") 'default-text-scale-decrease)

;; set c indentation to 4 spaces
(setq c-basic-offset 4)

;; additional packages
;;--------------------
;; yasnippet
;;-------------------
(require-package 'yasnippet)
(require 'yasnippet)
(yas-global-mode 0)
;; (yas-reload-all)
(add-hook 'ruby-mode-hook '(lambda () (yas-minor-mode)))
(add-hook 'html-mode-hook '(lambda () (yas-minor-mode)))

;;; use popup menu for yas-choose-value
(require 'popup)

;; add some shotcuts in popup menu mode
;; (define-key popup-menu-keymap (kbd "M-n") 'popup-next)
;; (define-key popup-menu-keymap (kbd "TAB") 'popup-next)
;; (define-key popup-menu-keymap (kbd "<tab>") 'popup-next)
;; (define-key popup-menu-keymap (kbd "<backtab>") 'popup-previous)
;; (define-key popup-menu-keymap (kbd "M-p") 'popup-previous)

(defun yas-popup-isearch-prompt (prompt choices &optional display-fn)
  (when (featurep 'popup)
    (popup-menu*
     (mapcar
      (lambda (choice)
        (popup-make-item
         (or (and display-fn (funcall display-fn choice))
             choice)
         :value choice))
      choices)
     :prompt prompt
     ;; start isearch mode immediately
     :isearch t
     )))

(setq yas-prompt-functions '(yas-popup-isearch-prompt yas-ido-prompt yas-no-prompt))

;;-----------
;; GO stuff
;;-----------
(require-package 'go-mode)

;;----------------
;; RVM integration
;;---------------
(require-package 'rvm)
(require 'rvm)

(defun rvm--rvmrc-read-version (path-to-rvmrc)
  (with-temp-buffer
    (insert-file-contents path-to-rvmrc)
    (while (re-search-forward "#.*$" nil t)
      (replace-match "" nil nil))
    (rvm--rvmrc-parse-version (buffer-string))))

;; this is a bad idea (will bork path when opening gems, for example)
;; (rvm-autodetect-ruby)

;;-----------
;; ruby stuff
;;-----------

(require 'ruby-compilation)

(defadvice ruby-compilation--adjust-paths (after ruby-compilation-fix-crs activate)
  "remove trailing carriage returns from ruby compilation output."
  (setq ad-return-value (replace-regexp-in-string "\r$" "" ad-return-value)))
;; (ad-unadvise 'ruby-compilation-adjust-paths)

(defun ruby-compilation-rake-unconditionally ()
  "run rake unconditionally."
  (interactive)
  (pop-to-buffer (ruby-compilation-do "rake" (list ruby-compilation-executable-rake))))

(defadvice ruby-compilation-do (before skaes/ruby-compilation-do activate)
  (rvm-activate-corresponding-ruby))

(add-hook 'ruby-mode-hook (lambda () (local-set-key (kbd "C-x r") 'ruby-compilation-rake-unconditionally)))
(add-hook 'ruby-mode-hook (lambda () (local-set-key (kbd "C-x t") 'ruby-compilation-this-test)))
(add-hook 'ruby-mode-hook (lambda () (local-set-key (kbd "C-x a") 'ruby-compilation-this-buffer)))

;; (defvar ruby-test-search-testcase-re
;;   "^[ \\t]*def[ \\t]+\\(test[_a-z0-9]*\\)")

;; (setq ruby-test-search-testcase-re
;;   "^[ \t]*test[ \t]+\"\\([^\n]*?\\)\"[ \t]+do[ \t]*\n")

(setq ruby-test-search-testcase-re
      "^[ \t]*test[ \t]+\"\\(.+?\\)\"[ \t]+do[ \t]*\n")

(defun ruby-compilation-this-test-name ()
  "find the first test case before point."
  (interactive)
  (save-excursion
    ;; (message "%s:%s" (current-buffer) (point))
    (forward-line)
    (if (re-search-backward ruby-test-search-testcase-re nil t)
	(concat "test_" (replace-regexp-in-string " " "_" (match-string-no-properties 1)))
      (message "no test case found")
      )))

(add-auto-mode 'ruby-mode "Appraisals\\'")

;;----------------
;; feature mode
;;---------------
(require-package 'feature-mode)

;;-------------------
;; Bells and whistles
;;-------------------
(set-frame-parameter (selected-frame) 'alpha '(0.999 0.9))
(add-to-list 'default-frame-alist '(alpha 0.999 0.9))

(eval-when-compile (require 'cl))
 (defun toggle-transparency ()
   (interactive)
   (if (/=
        (cadr (frame-parameter nil 'alpha))
        100)
       (set-frame-parameter nil 'alpha '(1.0 1.0))
     (set-frame-parameter nil 'alpha '(0.999 0.9))))
 (global-set-key (kbd "C-c t") 'toggle-transparency)

;; (setq ring-bell-function 'ignore)
(setq ring-bell-function
      `(lambda ()
        (call-process "afplay" nil 0 nil
                      "-v" "0.1" "/System/Library/Sounds/Pop.aiff")))

;;----------------------------------------------------------------------------
;; Interactively Do Things
;;----------------------------------------------------------------------------
(require 'ido)
(ido-mode t)

 ;; Display ido results vertically, rather than horizontally
(setq ido-decorations (quote ("\n-> " "" "\n   " "\n   ..." "[" "]" " [No match]" " [Matched]" " [Not readable]" " [Too big]" " [Confirm]")))
(defun ido-disable-line-trucation () (set (make-local-variable 'truncate-lines) nil))
(add-hook 'ido-minibuffer-setup-hook 'ido-disable-line-trucation)


(defun ido-find-file-in-tag-files ()
  (interactive)
  (save-excursion
    (let ((enable-recursive-minibuffers t))
      (visit-tags-table-buffer))
    (find-file
     (expand-file-name
      (ido-completing-read
       "Project file: " (tags-table-files) nil t)))))

(defun my-ido-project-files ()
  "Use ido to select a file from the project."
  (interactive)
  (let (my-project-root project-files tbl)
    (unless project-details (project-root-fetch))
    (setq my-project-root (cdr project-details))
    ;; get project files
    (setq project-files
          (split-string
           (shell-command-to-string
            (concat "find "
                    my-project-root
 " \\( -name \"*.svn\" -o -name \"*.git\" -o -name \"tmp\" -o -name \"log\" -o -name \"coverage\" -o -name \"plots\" \\) -prune -o -type f -a \\( -name '*.rb' -o -name '*.erb' \\) -print"
                    )) "\n"))
    ;; populate hash table (display repr => path)
    (setq tbl (make-hash-table :test 'equal))
    (let (ido-list)
      (mapc (lambda (path)
              ;; format path for display in ido list
              (setq key (replace-regexp-in-string "\\(.*?\\)\\([^/]+?\\)$" "\\2|\\1" path))
              ;; strip project root
              (setq key (replace-regexp-in-string my-project-root "" key))
              ;; remove trailing | or /
              (setq key (replace-regexp-in-string "\\(|\\|/\\)$" "" key))
              (puthash key path tbl)
              (push key ido-list)
              )
            project-files
            )
      (find-file (gethash (ido-completing-read "project-files: " ido-list) tbl)))))
;; bind to a key for quick access
(define-key global-map [f6] 'my-ido-project-files)

(defun my-ido-find-tag ()
  "Find a tag using ido"
  (interactive)
  (tags-completion-table)
  (let (tag-names)
    (mapc (lambda (x)
            (unless (integerp x)
              (push (prin1-to-string x t) tag-names)))
          tags-completion-table)
    (find-tag (ido-completing-read "Tag: " tag-names))))


;;----------------------------------------------------------------------------
;; full-ack
;;----------------------------------------------------------------------------
;; (require 'full-ack)
(autoload 'ack-same "full-ack" nil t)
(autoload 'ack "full-ack" nil t)
(autoload 'ack-find-same-file "full-ack" nil t)
(autoload 'ack-find-file "full-ack" nil t)

(require 'ag)
(setq ag-highlight-search t)
(setq ag-reuse-buffers 't)

;;----------------------------------------------------------------------------
;; Project Support
;;----------------------------------------------------------------------------
(require-package 'project-root)
(setq project-roots
      '(("Rails Project" :root-contains-files ("Rakefile" "app" "config" "lib" "log"))
        ("Gem Project" :root-contains-files (".git" "lib" "Rakefile"))
        ("C Project" :root-contains-files (".git" "Makefile"))
        ))

(defun project-root-rgrep ()
  "Run the grep command from the current project root."
  (interactive)
  (with-project-root (call-interactively 'rgrep)))

(global-unset-key (kbd "C-c p"))
(global-set-key (kbd "C-c p f") 'ack-find-file)
(global-set-key (kbd "C-c p t") 'ido-find-file-in-tag-files)
(global-set-key (kbd "C-c p s") 'ack-find-same-file)
(global-set-key (kbd "C-c p g") 'project-root-rgrep)
(global-set-key (kbd "C-c p a") 'ag)
(global-set-key (kbd "C-c p d") 'project-root-goto-root)
(global-set-key (kbd "C-c p p") 'project-root-run-default-command)

;; improved mode detection

(setq auto-mode-alist (cons '("Rakefile$" . ruby-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("rakefile$" . ruby-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("Vagrantfile$" . ruby-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("Gemfile$" . ruby-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("Capfile$" . ruby-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\.gemspec$" . ruby-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\.rake$" . ruby-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\.rxml$" . ruby-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\.rjs$" . ruby-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\.rtex$" . latex-mode) auto-mode-alist))

(add-hook 'ruby-mode-hook (lambda () (local-set-key [f5] 'sanityinc/ruby-toggle-hash-syntax)))

;; (require 'guess-offset)

;; turn off autofill in html-erb-mode
(require 'mmm-erb)
(add-hook 'html-erb-mode-hook (lambda () (auto-fill-mode 0)))

(add-hook 'comint-output-filter-functions 'comint-strip-ctrl-m t nil)
(add-hook 'compilation-filter-hook 'compile-strip-ctrl-m t nil)

(defvar com-filter-last-position 1)
(defun compile-strip-ctrl-m ()
  "Strip trailing `^M' characters from the current buffer."
  (interactive)
  (unless (local-variable-p 'com-filter-last-position)
    (make-local-variable 'com-filter-last-position)
    (setq com-filter-last-position (point-min)))
  (save-excursion
    (let ((end (point-max)))
      (goto-char com-filter-last-position)
      (while (re-search-forward "\r+$" end t)
        (replace-match "" t t))
      (setq com-filter-last-position end)
      )))



;;-------------------------------------------------------
;; reset colors when running inside terminal
;;-------------------------------------------------------
(unless window-system
  (progn
    (set-face-background 'default "black")
    (set-face-foreground 'default "white")
   ))

(provide 'init-local)
