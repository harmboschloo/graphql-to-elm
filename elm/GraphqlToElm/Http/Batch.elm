module GraphqlToElm.Http.Batch
    exposing
        ( post
        , send
        )

import Http
import GraphqlToElm.Graphql.Operation.Batch as Batch exposing (Batch)


post : String -> Batch a -> Http.Request a
post url batch =
    Http.post
        url
        (Http.jsonBody <| Batch.encode batch)
        (Batch.decoder batch)


send : (Result Http.Error a -> msg) -> Http.Request a -> Cmd msg
send =
    Http.send
