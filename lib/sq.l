# 20sep03abu
# (c) Software Lab. Alexander Burger

# (select [var ..] cls [hook] [var val ..])
(de select Lst
   (let
      (Vars
         (make
            (until
               (or
                  (atom Lst)
                  (and
                     (sym? (car Lst))
                     (= `(char "+") (char (car Lst))) ) )
               (link (pop 'Lst)) ) )
         Cls (pop 'Lst)
         Hook (and (isa '+Entity (car Lst)) (pop 'Lst)) )
      (default Lst
         (cons
            (or
               (car Vars)
               (cdr
                  (maxi caar
                     (getl (get (or Hook *DB) Cls)) ) ) ) ) )
      (let Q
         (goal
            (cons
               (make
                  (link
                     'select
                     '(@@)
                     (make
                        (for (L Lst L)
                           (link
                              (make
                                 (link (pop 'L) Cls)
                                 (and Hook (link Hook))
                                 (link (if L (pop 'L) '(NIL . T))) ) ) ) ) )
                  (while Lst
                     (let (Var (pop 'Lst)  Val (if Lst (pop 'Lst) '(NIL . T)))
                        (link
                           (list
                              (cond
                                 ((pair Val) 'range)
                                 ((or (num? Val) (ext? Val)) 'same)
                                 ((=T Val) 'bool)
                                 ((isa '+Fold (get Cls Var)) 'fold)
                                 ((isa '+Sn (get Cls Var)) 'tolr)
                                 (T 'head) )
                              Val '@@ Var ) ) ) ) ) ) )
         (use Obj
            (loop
               (NIL (setq Obj (cdr (asoq '@@ (prove Q)))))
               (ifn Vars
                  (show Obj)
                  (mapc
                     '((Var)
                        (cond
                           ((pair Var)
                              (print (apply get Var Obj)) )
                           ((meta Obj Var)
                              (print> @ (get Obj Var)) )
                           (T
                              (print (get Obj Var)) ) )
                        (space) )
                     Vars )
                  (print Obj) )
               (T (line)) ) ) ) ) )

(dm (print> . +Relation) (Val)
   (print Val) )

(dm (print> . +Number) (Val)
   (prin (format Val (: scl))) )

(dm (print> . +Date) (Val)
   (print (datStr Val)) )


# (update 'obj ['var])
(de update (Obj Var)
   (let *Dbg NIL
      (printsp Obj)
      (if Var
         (_update (get Obj Var) Var)
         (set!> Obj 'upd
            (any (revise (sym (val Obj)))) )
         (mapc
            '((X) (_update (or (atom X) (pop 'X)) X))
            (getl Obj) )
         Obj ) ) )

(de _update (Val Var)
   (printsp Var)
   (let New
      (if (meta Obj Var)
         (revise> @ Val)
         (any (revise (sym Val))) )
      (unless (= New Val)
         (if (mis> Obj Var New)
            (quit "mismatch" @)
            (put!> Obj 'upd Var New) ) ) ) )


(dm (revise> . +Relation) (Val)
   (any (revise (sym Val))) )

(dm (revise> . +Bag) (Lst)
   (mapcar
      '((V B) (space 6) (revise> B V))
      (any (revise (sym Lst)))
      (: bag) ) )

(dm (revise> . +Number) (Val)
   (format
      (revise (format Val (: scl)))
      (: scl) ) )

(dm (revise> . +Date) (Val)
   (expDat
      (revise
         (datStr Val)
         '((S) (list (datStr (expDat S)))) ) ) )

(dm (revise> . +List) (Val)
   (mapcar
      '((X) (space 3) (extra X))
      (any (revise (sym Val))) ) )