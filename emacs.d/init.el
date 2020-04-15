;;; init -- Nick's init.el
;;
;;; Commentary:
;;  Starting to sort out a better Emacs environment
;;
;;; Code:
(require 'server)
(if (not (eq t (server-running-p server-name)))
    (server-start))

(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  ;(add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  (add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  ;(add-to-list 'package-archives (cons "marmalade" (concat proto "://marmalade-repo.org/packages/")) t)
)
;(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
;(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/") t)
;(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t)
(package-initialize)

;(when (not package-archive-contents)
;  (package-refresh-contents))

;;; stuff to check out:
;; company-mode
;; web-mode (http://web-mode.org/)
;; custom-theme-*
;; flycheck-color-mode-line (currently broken in marmalade)


;                       yaml-mode
;                       sass-mode

;; Packages
(defvar my-packages '(flycheck
		      flycheck-color-mode-line
                      markdown-mode
                      nginx-mode
		      pony-mode
                      yaml-mode
                      sass-mode
		      cython-mode
		      ;yafolding
                      )
  "A list of packages to ensure are installed at launch.")

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))

(add-to-list 'load-path "~/.emacs.d/loadable")

(global-set-key [(control x)(control c)] 'server-edit)
(global-set-key [(control x)(meta c)] 'save-buffers-kill-emacs)

;; Slooooooow...
;;(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)

(autoload 'php-mode "php-mode" "PHP editing mode" t)
(add-to-list 'auto-mode-alist '("\\.php3\\'" . php-mode))
(add-to-list 'auto-mode-alist '("\\.php4\\'" . php-mode))
(add-to-list 'auto-mode-alist '("\\.php\\'" . php-mode))

;; (add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
;; (custom-set-variables
;;  '(js2-basic-offset 2)
;;  '(js2-bounce-indent-p t))

(add-to-list 'auto-mode-alist '("\\.ts$" . js-mode))
(add-to-list 'auto-mode-alist '("\\.js$" . js-mode))
(custom-set-variables
 '(js-indent-level 2))

;; ; directory node comes from first directory...

;; (setq Info-directory-list
;;       '(
;; 	"/usr/share/info"
;; 	"/usr/local/lib/info/"
;; 	"/usr/local/info/"
;; 	"/usr/local/share/info"
;; 	"/usr/info"
;; 	))

(defun toggle-modification-flag ()
  "Toggle the current buffer's modification flag."
  (interactive)
  (set-buffer-modified-p
   (not (buffer-modified-p))))

;; (global-set-key [(control x)(f)] 'fill-paragraph)
;; (global-set-key [(control c)(l)] 'goto-line)

; up and down-case things
(put 'upcase-region 'disabled nil)
(global-set-key [(control x)(meta u)] 'upcase-word)
(global-set-key [(control x)(meta l)] 'downcase-word)
(global-set-key [(control x)(meta U)] 'upcase-region)
(global-set-key [(control x)(meta L)] 'downcase-region)

; Mouse wheel - mwheel-scroll is used for normal scrolling in emacs22

(defun scroll-up-1 () "Scroll up 1 line." (interactive) (scroll-up 1))
(defun scroll-up-2 () "Scroll up 2 lines." (interactive) (scroll-up 2))
(defun scroll-up-3 () "Scroll up 3 lines." (interactive) (scroll-up 3))
(defun scroll-down-1 () "Scroll down 1 line." (interactive) (scroll-down 1))
(defun scroll-down-2 () "Scroll down 2 lines." (interactive) (scroll-down 2))
(defun scroll-down-3 () "Scroll down 3 lines." (interactive) (scroll-down 3))

;; 4-5 is scroll, 6-7 is horiz. scroll
;; M-mouse-4 is cmd-up, M-mouse-5 is cmd-down
;; S-mouse-6 is shift-up, S-mouse-7 is shift-down
;; why shift gives 6 & 7 who knows...
;;
(global-set-key [(S-mouse-6)] 'scroll-down-1)
(global-set-key [(S-mouse-7)] 'scroll-up-1)
(global-set-key [(S-double-mouse-6)] 'scroll-down-2)
(global-set-key [(S-double-mouse-7)] 'scroll-up-2)
(global-set-key [(S-triple-mouse-6)] 'scroll-down-3)
(global-set-key [(S-triple-mouse-7)] 'scroll-up-3)
;; (global-set-key [(shift button5)] 'scroll-up-3)
;; (global-set-key [(shift button4)] 'scroll-down-3)
(global-set-key [(mouse-6)] 'backward-word)
(global-set-key [(mouse-7)] 'forward-word)
(global-set-key [(M-mouse-4)] 'beginning-of-buffer)
(global-set-key [(M-mouse-5)] 'end-of-buffer)
(global-set-key [(M-mouse-6)] 'beginning-of-line)
(global-set-key [(M-mouse-7)] 'end-of-line)

; ctrl-~ only any good in X
(global-set-key [(control ~)(r)] 'toggle-read-only)
(global-set-key [(control ~)(m)] 'toggle-modification-flag)

; meta-~ not so easy, but OK in xterm
(global-unset-key [(meta ~)])
(global-set-key [(meta ~)(r)] 'toggle-read-only)
(global-set-key [(meta ~)(m)] 'toggle-modification-flag)

; hippie-expand!
;; on mac, cmd is meta but cmd-tab is intercepted by system
;; alt-tab is also not passed through :-(
;; meta / is usually dabbrev-expand
(global-unset-key [(control /)])
(global-set-key [(control /)] 'hippie-expand)

;; was:
;; (setq hippie-expand-try-functions-list
;;       '(try-complete-file-name-partially
;; 	try-complete-file-name
;; 	try-expand-all-abbrevs
;; 	try-expand-list
;; 	try-expand-line
;; 	try-expand-dabbrev
;; 	try-expand-dabbrev-all-buffers
;; 	try-expand-dabbrev-from-kill
;; 	try-complete-lisp-symbol-partially
;; 	try-complete-lisp-symbol))

;; also available:
;; try-expand-dabbrev-visible
;; try-expand-line-all-buffers
;; try-expand-list-all-buffers
;; try-expand-whole-kill

(require 'cperl-mode)
(setq cperl-indent-level 4)
;(cperl-set-style 'PerlStyle)

;; (setq lpr-switches '("-PLaser-240-lpd"))

; use "M-x desktop-save" to activate... unfortunately not for Xemacs >:(
;(desktop-load-default)
;(desktop-read)

;;(require 'mmm-auto)
;;(setq mmm-global-mode 'maybe)

;; (add-to-list 'auto-mode-alist '("\\.mas\\'" . html-mode))
;; (mmm-add-mode-ext-class 'html-mode "\\.mas\\'" 'mason)

;; (add-to-list 'auto-mode-alist '("\\.msn\\'" . html-mode))
;; (mmm-add-mode-ext-class 'html-mode "\\.msn\\'" 'mason)


(setq backup-by-copying t)
(setq line-number-mode t)
(setq column-number-mode t)
(setq-default ispell-program-name "aspell")

(add-hook `cperl-mode-hook `turn-on-font-lock)
(add-hook `html-mode-hook `turn-on-font-lock)
(add-hook `python-mode-hook `turn-on-font-lock)
(add-hook `python-mode-hook `(lambda() (modify-syntax-entry ?_ "_" python-mode-syntax-table)))

;; (require 'un-define)
;; (set-default-coding-systems 'utf-8)
;; (set-terminal-coding-system 'utf-8)
(set-clipboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

(fringe-mode 8)
(menu-bar-right-scroll-bar)

;; CPerl, please...
(mapc
 (lambda (pair)
   (if (eq (cdr pair) 'perl-mode)
       (setcdr pair 'cperl-mode)))
 (append auto-mode-alist interpreter-mode-alist))

;; eldoc not working immediately, and requires extra
;; 'yes' to kill python process on exit
;; (add-hook 'python-mode-hook 'turn-on-eldoc-mode)


;; Flycheck
(require 'flycheck)
;;(setq flycheck-pylintrc "~/.pylintrc")
(require 'flycheck-color-mode-line)
(setq-default flycheck-emacs-lisp-load-path load-path)

(add-hook 'after-init-hook #'global-flycheck-mode)
(eval-after-load "flycheck"
  '(add-hook 'flycheck-mode-hook 'flycheck-color-mode-line-mode))

;; ;; For more on flymake (with other languages etc.),
;; ;; see http://www.emacswiki.org/emacs/FlyMake

;; ;; For use with Python, see http://www.emacswiki.org/emacs/PythonMode
;; ;;
;; ;;(autoload 'flymake-mode "flymake" "On-the-fly syntax checking minor mode" t)
;; (when (load "flymake" t)
;;   (defun flymake-pylint-init ()
;;     (let* ((temp-file (flymake-init-create-temp-buffer-copy
;; 		       'flymake-create-temp-inplace))
;;            (local-file (file-relative-name
;;                         temp-file
;;                         (file-name-directory buffer-file-name))))
;;       (list "epylint" (list local-file))))
  
;;   (add-to-list 'flymake-allowed-file-name-masks
;;                '("\\.py\\'" flymake-pylint-init)))

;; (add-hook `python-mode-hook `flymake-mode)

;; ;; for html
;; (defun flymake-html-init ()
;;   (let* ((temp-file (flymake-init-create-temp-buffer-copy
;; 		     'flymake-create-temp-inplace))
;; 	 (local-file (file-relative-name
;; 		      temp-file
;; 		      (file-name-directory buffer-file-name))))
;;     (list "tidy" (list local-file))))

;; (add-to-list 'flymake-allowed-file-name-masks
;; 	     '("\\.html$\\|\\.ctp" flymake-html-init))

;; (add-to-list 'flymake-err-line-patterns
;; 	     '("line \\([0-9]+\\) column \\([0-9]+\\) - \\(Warning\\|Error\\): \\(.*\\)"
;; 	       nil 1 2 4))

;; ;; see http://github.com/purcell/emacs.d/blob/master/site-lisp/flymake-ruby/flymake-ruby.el
;; ;;

;; Not available in Ubuntu eoan - install elpa-color-theme-modern when focal
;; arrives
;(require 'color-theme)
;(load-file "~/.emacs.d/emacs-color-theme-x-nwp")
;(load-file "~/.emacs.d/emacs-color-theme-tty-nwp")
;
;; select theme - first list element is for windowing system, second is for console/terminal
;(defvar color-theme-choices)
;(setq color-theme-choices
;      '(nwp-x-color-theme nwp-tty-color-theme))
;
;; See http://www.emacswiki.org/emacs/ColorTheme
;;
;
;; default-start
;(funcall (lambda (cols)
;    	   (let ((color-theme-is-global nil))
;    	     (eval
;    	      (append '(if window-system)
;    		      (mapcar (lambda (x) (cons x nil))
;    			      cols)))))
;    	 color-theme-choices)

;; test for each additional frame or console

;; bizarre eval-when-compile to avoid warning about cl;
;; see http://dto.github.io/notebook/require-cl.html#sec-8
;; (eval-when-compile (require 'cl))
;; No longer necessary; new way:
;(require 'cl-lib)
;(fset 'test-win-sys
;      (funcall (lambda (cols)
;    		 (lexical-let ((cols cols))
;    		   (lambda (frame)
;    		     (let ((color-theme-is-global nil))
;		       ;; must be current for local ctheme
;		       (select-frame frame)
;		       ;; test winsystem
;		       (eval
;; window-system a variable not a function (in emacs22)
;;			(append '(if (window-system frame))
;			(append '(if window-system)
;				(mapcar (lambda (x) (cons x nil))
;					cols)))))))
;   	       color-theme-choices ))
;; hook on after-make-frame-functions
;(add-hook 'after-make-frame-functions 'test-win-sys)

;; end per-frame color theme selection from http://www.emacswiki.org/emacs/ColorTheme


;; For Emacs' supplied python mode
;; (defadvice python-calculate-indentation (around outdent-closing-brackets)
;;   "Handle lines beginning with a closing bracket and indent them so that
;; they line up with the line containing the corresponding opening bracket."
;;   (save-excursion
;;     (beginning-of-line)
;;     (let ((syntax (syntax-ppss)))
;;       (if (and (not (eq 'string (syntax-ppss-context syntax)))
;;                (python-continuation-line-p)
;;                (cadr syntax)
;;                (skip-syntax-forward "-")
;;                (looking-at "\\s)"))
;;           (progn
;;             (forward-char 1)
;;             (ignore-errors (backward-sexp))
;;             (setq ad-return-value (current-indentation)))
;;         ad-do-it))))

;; (ad-activate 'python-calculate-indentation)

;; (defun python-use-ipython (cmd args)
;;   "Setup to use CMD as ipython with given ARGS."
;; ;;  (setq ipython-command cmd)
;; ;;  (setq py-python-command-args args)
;;   (require 'ipython)
;;   (setq ipython-completion-command-string
;;         "print(';'.join(__IP.Completer.all_completions('%s')))\n"))

;; (python-use-ipython "/usr/bin/ipython" '("-colors" "LightBG" "-nobanner"))

;; Python
;(add-hook 'python-mode-hook 'auto-complete-mode)
;(add-hook 'python-mode-hook 'jedi:ac-setup)
;(add-hook 'python-mode-hook 'whitespace-mode)

;;; bind RET to py-newline-and-indent
(add-hook 'python-mode-hook
	  '(lambda ()
	     (define-key py-mode-map "\C-m" 'newline-and-indent)))

;;; Electric Pairs
;; consider skeleton-pair-insert-maybe, see http://www.emacswiki.org/emacs/AutoPairs
(add-hook 'python-mode-hook 'electric-pair-mode)

;; No tabs in Python!
(add-hook 'python-mode-hook '(lambda () (setq indent-tabs-mode nil)))

; Don't edit python bytecode
(add-to-list 'completion-ignored-extensions ".pyc")

;;(require 'cython-mode)
;;(add-to-list 'auto-mode-alist '("\\.pyx\\'" . cython-mode))
;;(add-to-list 'auto-mode-alist '("\\.pxd\\'" . cython-mode))
;;(add-to-list 'auto-mode-alist '("\\.pxi\\'" . cython-mode))

;;; Pymacs
;(autoload 'pymacs-apply "pymacs")
;(autoload 'pymacs-call "pymacs")
;(autoload 'pymacs-eval "pymacs" nil t)
;(autoload 'pymacs-exec "pymacs" nil t)
;(autoload 'pymacs-load "pymacs" nil t)
;(autoload 'pymacs-autoload "pymacs")

;;(eval-after-load "pymacs"
;;  '(add-to-list 'pymacs-load-path YOUR-PYMACS-DIRECTORY"))

;;; ropemacs
;; need newer version of python-rope (than 0.9.2) to work in mercurial repos
;(pymacs-load "ropemacs" "rope-")
(defvar ropemacs-enable-autoimport)
(setq ropemacs-enable-autoimport t)

;; shell scripts
(setq-default sh-basic-offset 2)
(setq-default sh-indentation 2)

;; nginx
(require 'nginx-mode)

;; Seems this is the actual culprit for python mode slowness
;;(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)

(when (locate-library "mercurial")
  (autoload 'hg-find-file-hook "mercurial")
  (add-hook 'find-file-hooks 'hg-find-file-hook))

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(line-move-visual nil)
 '(inhibit-startup-screen t)
 '(mouse-wheel-scroll-amount (quote (1 ((shift) . 3) ((alt)) ((control)))))
 '(scroll-bar-mode (quote right)))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

;; End:
;;; init.el ends here
