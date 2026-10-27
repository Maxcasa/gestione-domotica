# Gestione Domotica — Installazione e migrazione app 2.x

Questa guida e' per chi prepara, distribuisce e configura la app Flutter nativa
`gestione-domotica 2.0.0+1` su Android o iOS. La release 2 e' una major
incompatibile con il vecchio provisioning: ogni installazione deve registrarsi
nuovamente presso `domo-server` tramite enrollment v2 HTTPS.

La guida non sostituisce le istruzioni server: il backend, Mosquitto, Dynamic
Security, certificato HTTPS, DNS e firewall devono essere pronti prima di
registrare il primo telefono. Nel repository associato `domo-server` consultare
`doc/RELEASE-2-INSTALLAZIONE-E-MIGRAZIONE.md` per la procedura lato Raspberry.

## 1. Modifiche visibili all'utente

- Sono supportati Android e iOS nativi; Flutter Web non e' supportato.
- La funzione camera e' stata rimossa.
- L'app usa un solo broker MQTT domestico: porta `1883` in LAN e tramite
  Tailscale, senza TLS MQTT aggiuntivo.
- Il traffico remoto passa attraverso Tailscale; il broker richiede comunque
  autenticazione e ACL.
- Le credenziali MQTT sono generate dal backend per ogni installazione e
  conservate nel keystore/keychain del sistema operativo. Non sono visualizzate
  dall'app e non vanno copiate in file o condivise.
- L'enrollment invia il codice di pairing solo a un endpoint HTTPS con
  certificato e hostname verificati. Non esiste fallback HTTP.
- I dati descrittivi dei vecchi profili possono essere conservati, ma le
  credenziali legacy vengono scartate. Il profilo mostra **Registrazione
  richiesta** finche' non viene effettuato un nuovo enrollment.

## 2. Requisiti prima di distribuire l'app

Chiedere all'amministratore del sistema:

1. l'hostname MagicDNS Tailscale completo del Raspberry, corrispondente al
   certificato HTTPS, ad esempio `raspberry-nome.tailnet.ts.net`;
2. la porta HTTPS di enrollment, normalmente `8443`;
3. il token di pairing corrente, trasmesso tramite un canale amministrativo
   protetto;
4. conferma che API v2, Dynamic Security, ACL deny, firewall e broker MQTT
   `1883` siano attivi e collaudati;
5. il nome/IP LAN stabile e il nome della rete Wi-Fi, se non gia' forniti
   dall'enrollment.

Il token di pairing autorizza nuovi enrollment ed e' un segreto. Non inserirlo
in ticket, repository, QR pubblici o chat non protette. Non e' la password
MQTT del telefono.

Sul dispositivo:

- installare Tailscale e autenticarsi nel tailnet autorizzato;
- mantenere automatiche data e ora, necessarie alla validazione dei certificati;
- concedere le notifiche all'app se si desidera ricevere allarmi FCM;
- non installare certificati sconosciuti e non accettare o aggirare errori TLS.

## 3. Installazione e distribuzione della build

### Installare una build rilasciata

Distribuire esclusivamente gli artefatti firmati approvati per la release:

- **Android:** APK firmato per installazione gestita oppure Android App Bundle
  caricato nel canale di distribuzione scelto. Se l'installazione e' manuale,
  verificare firma e provenienza del file e consentire il sideload soltanto se
  previsto dalla policy del dispositivo.
- **iOS:** distribuire tramite App Store, TestFlight o un canale aziendale
  firmato e gestito. Il caricamento iOS richiede macOS, Xcode e la firma Apple
  configurata per il progetto.

Installare la versione 2 sopra la precedente se il sistema operativo e il
canale lo consentono; non cancellare i dati dell'app durante l'aggiornamento,
altrimenti si perderanno profili e preferenze locali non segrete. Se il canale
richiede una disinstallazione, salvare solo i dati che la policy consente e
prepararsi a ricreare i profili con enrollment.

### Ricostruire la build dal sorgente

Requisiti: Flutter/Dart compatibili con i vincoli SDK in `pubspec.yaml`,
toolchain Android per Android o macOS/Xcode per iOS, e checkout locale della
dipendenza `multi_flutter_circular_slider`. Quest'ultima e' una dipendenza
esterna con path locale e deve essere presente nel percorso indicato da
`pubspec.yaml` prima di risolvere i pacchetti.

Dalla directory del repository:

```sh
flutter pub get
flutter test
flutter analyze
```

Il progetto puo' avere warning preesistenti di analisi; esaminare l'output e
non ignorare nuovi errori relativi alla release. Per generare gli artefatti:

```sh
flutter build appbundle --release
```

Per APK distribuibile fuori dallo store:

```sh
flutter build apk --release
```

Per iOS, eseguire su macOS dopo aver configurato firma, bundle identifier e
provisioning:

```sh
flutter build ipa --release
```

Conservare insieme a ogni artefatto il commit/tag sorgente, la versione Flutter,
il risultato dei test, le impostazioni di firma e il checksum. Non includere
token di pairing, credenziali MQTT, chiavi private o file `.env` nella build.
Incrementare il build number quando si pubblicano aggiornamenti successivi
allo stesso `2.0.0`.

## 4. Primo avvio e enrollment

Ripetere la registrazione su ogni telefono/tablet. Ogni installazione riceve
un'identita' MQTT indipendente; non riutilizzare credenziali generate su un
altro telefono.

1. Aprire l'app **Gestione Domotica** e accedere alla schermata **Configurazione**
   dal menu.
2. Se il profilo precedente mostra **Registrazione richiesta**, premere il
   pulsante **+** accanto al selettore delle connessioni.
3. Compilare il modulo:

   | Campo | Valore |
   |---|---|
   | Token di pairing | Token corrente fornito dall'amministratore; inserirlo senza spazi aggiuntivi. |
   | Server (hostname MagicDNS) | Nome DNS completo `.ts.net` del Raspberry, senza schema, porta o slash. Deve corrispondere al certificato HTTPS. |
   | Porta HTTPS | `8443`, a meno che l'amministratore non abbia configurato una porta diversa. Non e' la porta MQTT. |
   | Nome dispositivo | Etichetta non vuota utile a riconoscere il telefono nel broker, ad esempio `Telefono cucina`. |

4. Premere **+** nel modulo. Il client invia `POST /api/v2/enrollment` via
   HTTPS, non segue redirect e non riprova su HTTP. Una risposta corretta e'
   HTTP `201` con `apiVersion: 2`; l'app salva username/password MQTT nel
   keystore/keychain e chiude il modulo mostrando l'esito.
5. Selezionare il profilo appena registrato. Il backend invia i dati di
   connessione e dominio; non inserire manualmente password o username MQTT.
6. Espandere i dettagli della configurazione e verificare:
   - **Server Name:** hostname/IP LAN stabile del Raspberry raggiungibile su
     HTTP 8085;
   - **Local WiFi Name:** premere **Local WiFi** per leggere il nome attuale o
     inserire il valore previsto dall'impianto;
   - premere **Submit** dopo ogni correzione.

   Il routing LAN non si basa sull'SSID: l'app verifica l'health check HTTP
   sulla porta `8085` con timeout breve. Se il server locale non risponde,
   passa all'hostname Tailscale. Il campo Wi-Fi deve comunque essere non vuoto
   per la configurazione del profilo.
7. Confermare che l'indicatore MQTT mostri una connessione attiva. Provare
   prima la lettura di uno stato/sensore e poi un comando innocuo, verificando
   che sia applicato una sola volta.

La connessione remota richiede Tailscale attivo sul telefono. Le credenziali
MQTT sono le stesse sul percorso LAN e Tailscale; l'app usa il broker sulla
porta `1883`.

## 5. Aggiornamento dalla app precedente

La release 2 non e' retrocompatibile con il bootstrap della versione
precedente:

1. Preparare prima il backend 2.x e collaudarlo con un dispositivo pilota.
   Non aggiornare i telefoni prima di avere endpoint HTTPS, certificato,
   plugin Dynamic Security e ACL pronti.
2. Aggiornare l'app dal canale ufficiale, senza cancellarne i dati se possibile.
   L'app conserva i campi descrittivi utili, ma elimina username/password
   legacy dal profilo e bonifica una sola volta le copie obsolete dallo storage
   sicuro. Le vecchie credenziali non vengono riutilizzate.
3. Effettuare l'enrollment v2 come descritto sopra. Se ci sono piu' sistemi
   domotici, registrare ciascun profilo; lo stesso `remoteDomain` aggiorna il
   profilo corrispondente. Ogni registrazione crea un nuovo account MQTT sul
   server: dopo aver verificato il nuovo accesso, chiedere all'amministratore
   di revocare il vecchio account del telefono, identificato dal device ID o
   dal nome dispositivo.
4. Verificare app, notifiche, stati e comandi in LAN e poi via Tailscale prima
   di procedere con gli altri telefoni.
5. L'aggiornamento dell'app non revoca da solo account MQTT gia' provisionati
   sul server. L'amministratore deve disabilitare/eliminare in Dynamic Security
   gli account dei dispositivi non piu' autorizzati.

### Problemi comuni

| Sintomo | Verifiche |
|---|---|
| Errore certificato/TLS | Ora automatica; hostname inserito identico al nome nel certificato; catena attendibile; niente IP al posto del nome MagicDNS. Non disabilitare la validazione. |
| Server non raggiungibile | Telefono connesso alla LAN o Tailscale; hostname MagicDNS risolve; porta HTTPS aperta dal firewall per la rete autorizzata; backend attivo. |
| HTTP 401 o pairing rifiutato | Token corretto e aggiornato; evitare tentativi ripetuti (il server applica rate limiting); contattare l'amministratore. |
| HTTP 503 / enrollment non configurato | Verificare lato Raspberry Dynamic Security, default ACL deny, credenziali e configurazione del dominio MagicDNS. |
| Registrazione richiesta ancora visibile | Enrollment non concluso o profilo non selezionato; verificare il messaggio di errore e ripetere una volta risolto il problema server. |
| MQTT non si connette dopo enrollment | Verificare Tailscale/LAN, porta 1883, account generato attivo e ACL del relativo `remoteDomain`. Non modificare credenziali nell'app. |
| Notifiche assenti | Permesso notifiche del sistema operativo, token FCM e topic `<remoteDomain>_allarme` / `<remoteDomain>_sensori` lato backend. |

In caso di errore TLS o di configurazione non tentare un fallback HTTP,
certificati ignorati o credenziali MQTT condivise. Fornire all'amministratore
solo codice/ora dell'errore e versione dell'app, mai il token o la password.

## 6. Revoca, reinstallazione e supporto

- La rimozione dell'app o del profilo locale non revoca l'account sul broker.
  Richiedere all'amministratore di disabilitare/eliminare l'identita' del
  dispositivo in Dynamic Security.
- Dopo una reinstallazione con cancellazione dati, eseguire un nuovo enrollment
  per ottenere credenziali nuove; richiedere la revoca dell'account precedente.
- Proteggere il dispositivo con PIN/biometria e mantenere sistema operativo e
  app aggiornati. In caso di smarrimento del telefono, chiedere subito la
  revoca del relativo client MQTT.
- Non inviare database locali, screenshot con token, log contenenti dati
  sensibili o dump dello storage sicuro nei report di assistenza.
