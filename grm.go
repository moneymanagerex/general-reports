package main

import (
    "os"
    "fmt"
    "github.com/julienschmidt/httprouter"
    "net/http"
    "log"
)

func Index(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
    dir, err := os.Open(".")
    if err != nil {
        return
    }

    fileInfos, err := dir.Readdir(-1)
    if err != nil {
        return
    }
    for _, fi := range fileInfos {
        if fi.IsDir() {
            fmt.Fprint(w, "<a href=\"", fi.Name(), "\">", fi.Name(), "</a>")
        }
    }
}

func Report(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
    fmt.Fprintf(w, "hello, %s!\n", ps.ByName("report"))
}

func main() {
    router := httprouter.New()
    router.GET("/", Index)
    router.GET("/:report", Report)

    log.Fatal(http.ListenAndServe(":8080", router))
}
