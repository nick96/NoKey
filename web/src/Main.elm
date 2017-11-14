module Main exposing (..)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onInput, onSubmit, onClick)
import Random.Pcg as Random exposing (Generator)


--

import PasswordGenerator exposing (CharSet, PasswordRequirements, PasswordRequirementsState)


type alias Model =
    { sites : List PasswordPart
    , newSiteEntry : PasswordMetaData
    , expandSiteEntry : Bool
    , requirementsState : PasswordRequirementsState
    , seed : Random.Seed
    }


type alias PasswordMetaData =
    { securityLevel : Int
    , length : Int
    , siteName : String
    , userName : String
    }


defaultMetaData : PasswordMetaData
defaultMetaData =
    { securityLevel = 2, length = 16, siteName = "", userName = "" }


resetMeta : PasswordMetaData -> PasswordMetaData
resetMeta meta =
    { meta | siteName = "" }


type alias PasswordPart =
    { pw : Random.Seed, meta : PasswordMetaData, requirements : PasswordRequirements }


splitPassword : PasswordMetaData -> PasswordRequirementsState -> Random.Seed -> PasswordPart
splitPassword meta req seed =
    -- TODO: the seed is the actual password!
    -- since the seed IS the password, it should have at least as many bytes of randomness as the desired password length!
    -- Use the seed that was used to generate the password and split it into parts.
    -- Use Shamir's secret sharing algorithm
    PasswordPart (seed) meta (PasswordGenerator.getRequirements req)


initModel : Model
initModel =
    { sites = []
    , newSiteEntry = defaultMetaData
    , expandSiteEntry = False
    , requirementsState = PasswordGenerator.requirementsInitState
    , seed = Random.initialSeed 227852861
    }


init =
    initModel


type Msg
    = AddPassword
    | NewSiteEntry String
    | SecurityLevel Int
    | SetPasswordRequirements PasswordRequirementsState
    | GenerateNewPassword


update : Msg -> Model -> Model
update msg model =
    case msg of
        AddPassword ->
            let
                pwPart =
                    splitPassword model.newSiteEntry model.requirementsState model.seed
            in
                { model | sites = pwPart :: model.sites, newSiteEntry = resetMeta model.newSiteEntry, expandSiteEntry = False }
                    |> update GenerateNewPassword

        NewSiteEntry s ->
            { model | newSiteEntry = (\e -> { e | siteName = s }) model.newSiteEntry, expandSiteEntry = not <| String.isEmpty s }

        SecurityLevel n ->
            { model | newSiteEntry = (\e -> { e | securityLevel = n }) model.newSiteEntry }

        GenerateNewPassword ->
            { model | seed = Tuple.second <| Random.step (Random.independentSeed) model.seed }

        SetPasswordRequirements state ->
            { model | requirementsState = state }


view : Model -> Html Msg
view model =
    Html.div []
        [ newSiteForm model.requirementsState model.expandSiteEntry model.newSiteEntry model.seed
        , viewSavedSites model.sites
        ]


viewSavedSites : List PasswordPart -> Html Msg
viewSavedSites sites =
    Html.div []
        (List.map
            (\({ meta } as spw) ->
                Html.div [] [ Html.h3 [] [ Html.text meta.siteName ], Html.text (toString spw) ]
            )
            sites
        )


newSiteForm : PasswordRequirementsState -> Bool -> PasswordMetaData -> Random.Seed -> Html Msg
newSiteForm requirementsState expandSiteEntry entry seed =
    let
        pw =
            Tuple.first (Random.step (PasswordGenerator.randomPassword entry.length (PasswordGenerator.getRequirements requirementsState)) seed)
    in
        Html.div []
            [ Html.form [ onSubmit GenerateNewPassword ]
                [ Html.text "New Site: "
                , Html.input [ Attr.placeholder "example.com", Attr.value entry.siteName, onInput NewSiteEntry ] []
                ]
            , (if not expandSiteEntry then
                Html.text ""
               else
                Html.div []
                    ([ Html.text "Security Level: "
                     , Html.input
                        [ Attr.type_ "number"
                        , Attr.min "2"

                        -- TODO: limit max by number of available devices.
                        , Attr.max "5"
                        , Attr.value (toString entry.securityLevel)
                        , onInput (\s -> String.toInt s |> Result.withDefault 2 |> SecurityLevel)
                        ]
                        []
                     , PasswordGenerator.viewRequirements SetPasswordRequirements requirementsState
                     ]
                        ++ case pw of
                            Ok thePw ->
                                [ Html.text "your new password: "
                                , Html.text thePw
                                , Html.div
                                    []
                                    [ Html.button [ onClick AddPassword ] [ Html.text "OK" ]
                                    , Html.button [ onClick GenerateNewPassword ] [ Html.text "Generate another one!" ]
                                    ]
                                ]

                            Err e ->
                                [ Html.text e ]
                    )
              )
            ]


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { model = init
        , view = view
        , update = update
        }
