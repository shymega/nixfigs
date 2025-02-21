;;; elfeed.el --- sets up elfeed
;;; commentary:
;;; code:

;;; set feeds for elfeed
;;; i don't like this method of passing tokens in the URL. Granted, it doesn't contain critical information, but it's not great otherwise.
;;; if the worst comes to the worst, I'll just create a script that automates changing the token every couple of days.
(defvar elfeed-feeds '("https://rss.shymega.org.uk/index.xml"))

;;; set key-binding for elfeed
(global-set-key (kbd "C-x w") 'elfeed)

(provide 'shy-elfeed)
;;; elfeed.el ends here
