
echo "\$TTL 604800
@   IN  SOA servidor.udenar.co. root.udenar.co. (
                  2         ; Serial
             604800         ; Refresh
              86400         ; Retry
            2419200         ; Expire
             604800 )       ; Negative Cache TTL
;
                     IN  NS     servidor.udenar.co.
servidor             IN  A      172.16.0.2
cliente1             IN  A      172.16.0.51
router               IN  A      172.16.0.1
cliente2.udenar.co.  IN  A      172.16.0.52
server               IN  CNAME  servidor
correo               IN  A      172.16.0.2
udenar.co.           IN  MX 10  correo



echo "\$TTL 604800
@   IN  SOA servidor.udenar.co. root.udenar.co. (
                  3         ; Serial
             604800         ; Refresh
              86400         ; Retry
            2419200         ; Expire
             604800 )       ; Negative Cache TTL
;
;
    IN  NS  servidor.undear.co.
2   IN  PTR servidor.udenar.co.
51  IN  PTR cliente1.udenar.co.
1   IN  PTR router.udenar.co.
52  IN  PTR cliente2.udenar.co.
2   IN  PTR correo.udenar.co.
