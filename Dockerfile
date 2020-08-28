FROM haproxy:2.2

COPY run.sh /run.sh

CMD ["/bin/bash", "/run.sh"]
