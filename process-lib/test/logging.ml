open! Core.Std
open! Expect_test_helpers_kernel.Std

open Import

let%expect_test _ =
  let log sexp =
    Printf.printf !"%{sexp:Sexp.t}\n%!" (cleanup_sexp sexp)
  in
  Process.Logged.eval ~context ~log
    (P.with_temp_dir ~prefix:"shexp-debugging" ~suffix:tmpdir_suffix
       (fun tmpdir ->
          P.chdir tmpdir
            (P.stdout_to "blah" (P.echo "Bonjour les amis")
             >> P.run "cat" ["blah"]
             >> P.run "sed" ["s/o/a/g"; "blah"]
             >> P.echo "C'est finit!")));
  [%expect {|
    ((thread 0) (id 0)
     (generate-temporary-directory (prefix shexp-debugging) (suffix <temp-dir>)))
    ((thread 0) (id 0) -> <temp-dir>)
    ((thread 0) (id 1) (chdir <temp-dir>))
    ((thread 0) (id 1) -> ())
    ((thread 0) (id 2)
     (open-file (perm 0o666) (flags (O_WRONLY O_CREAT O_TRUNC)) blah))
    ((thread 0) (id 2) -> 34)
    ((thread 0) (id 3) (set-ios (stdout) 34))
    ((thread 0) (id 3) -> ())
    ((thread 0) (id 4) (echo "Bonjour les amis"))
    ((thread 0) (id 4) -> ())
    ((thread 0) (id 5) (close-fd 34))
    ((thread 0) (id 5) -> ())
    ((thread 0) (id 6) (run cat (blah)))
    Bonjour les amis
    ((thread 0) (id 6) -> (Exited 0))
    ((thread 0) (id 7) (run sed (s/o/a/g blah)))
    Banjaur les amis
    ((thread 0) (id 7) -> (Exited 0))
    ((thread 0) (id 8) (echo "C'est finit!"))
    C'est finit!
    ((thread 0) (id 8) -> ())
    ((thread 0) (id 9) (chdir <temp-dir>))
    ((thread 0) (id 9) -> ())
    ((thread 0) (id 10) (readdir .))
    ((thread 0) (id 10) -> (blah))
    ((thread 0) (id 11) (lstat blah))
    ((thread 0) (id 11) -> <stats>)
    ((thread 0) (id 12) (rm blah))
    ((thread 0) (id 12) -> ())
  |}]
