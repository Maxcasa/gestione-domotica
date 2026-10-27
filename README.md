# gestione-domotica
Flutter App per la gestione domotica della casa

## Documentazione release 2

Per installazione, distribuzione Android/iOS, migrazione dalla versione
precedente e registrazione del telefono, seguire la
[guida completa app 2.x](doc/RELEASE-2-INSTALLAZIONE-E-MIGRAZIONE.md).

## Dipendenze esterne

Il pacchetto `multi_flutter_circular_slider` e' un repository separato, atteso come checkout affiancato: con questo workspace (`D:\PP\max-domotica\gestione-domotica`) il percorso in `pubspec.yaml` e' `../../multi-flutter_circular-slider/`, cioe' `D:\PP\multi-flutter_circular-slider`. Va clonato a parte prima di `flutter pub get`.

## Connessione (release 2)

- Supportate solo le piattaforme native Android/iOS (rimosso il supporto web). La funzione camera e' stata rimossa.
- Registrazione: la richiesta `POST https://<server>:<porta HTTPS>/api/v2/enrollment` usa **solo HTTPS** con verifica del certificato e dell'hostname (consigliato hostname MagicDNS Tailscale con certificato valido), senza redirect ne' fallback HTTP. Dal menu "+" della pagina di configurazione si inseriscono token di pairing, server, porta HTTPS (default 8443) e nome dispositivo.
- La risposta contiene username/password MQTT per-dispositivo: sono salvate solo nello storage sicuro del sistema operativo (Keystore/Keychain), mai in asset, file JSON o log. Risposte con `apiVersion` diversa da 2 o forma non valida vengono rifiutate con un errore visibile.
- MQTT: porta 1883, senza TLS, sulla LAN o sulla tailnet con lo stesso account. La LAN e' preferita se l'health check HTTP (`http://<server locale>:8085/`, timeout 2 s) risponde, altrimenti si usa l'host tailnet; l'SSID WiFi non e' usato come prova di raggiungibilita'.
- Le credenziali presenti in vecchi file locali NON vengono migrate (la release 2 le revoca): al primo avvio sono rimosse dal profilo e dal file, le eventuali copie obsolete nello storage sicuro vengono cancellate una sola volta, e i dati non sensibili del profilo sono conservati. Il profilo risulta "Registrazione richiesta" finche' non si esegue un nuovo enrollment, le cui credenziali non vengono mai sovrascritte dalla bonifica. Gli asset di esempio non contengono credenziali.
