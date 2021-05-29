(quicklisp-quickstart:install)
(ql:quickload :ichiran)
(ichiran/mnt:add-errata)
(ichiran/test:run-all-tests)

(ql:quickload :ichiran/cli)
(ichiran/cli:build)
