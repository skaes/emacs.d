;;; rdoc.el --- major mode for editing rdoc files

;;; Commentary:
;;; downloaded from https://raw.githubusercontent.com/jbpros/emacs-setup/master/rdoc/rdoc-mode.el

;;; Code:

(defface rdoc-header-1
  '((t (:inherit variable-pitch :foreground "cyan" :weight bold :height 1.4)))
  "rdoc mode header level 1"
  :group 'rdoc)

(defface rdoc-header-2
  '((t (:inherit variable-pitch :foreground "cyan" :weight bold :height 1.3)))
  "rdoc mode header level 2"
  :group 'rdoc)

(defface rdoc-header-3
  '((t (:inherit variable-pitch :foreground "cyan" :weight bold :height 1.2)))
  "rdoc mode header level 3"
  :group 'rdoc)

(defface rdoc-header-4
  '((t (:inherit variable-pitch :foreground "cyan" :weight bold :height 1.1)))
  "rdoc mode header level 4"
  :group 'rdoc)

(define-generic-mode 'rdoc-mode
  ()					;comment-list
  '()					;keyword-list
  '(					;font-lock-list
    ("^=[^=].*" . 'rdoc-header-1)
    ("^==[^=].*" . 'rdoc-header-2)
    ("^===[^=].*" . 'rdoc-header-3)
    ("^====[^=].*" . 'rdoc-header-4)
    ("^[\\*#]\\{1,9\\} " . 'bold)
    ("\\(?:[^a-zA-Z0-9]\\)?\\*[^*]+\\*\\(?:[^a-zA-Z0-9]\\)" . 'bold)
    ("\\(?:[^a-zA-Z0-9]\\)?\\_[^_]+\\_\\(?:[^a-zA-Z0-9]\\)" . 'italic)
    )
  '("README_FOR_APP" "\\.rdoc$")	;auto-mode-list
  '((lambda () (auto-fill-mode t)))	;function-list
  "Major mode for editing RDOC files.")

(provide 'rdoc-mode)

;;; rdoc-mode.el ends here


