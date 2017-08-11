#!/usr/bin/env sh

readonly OUT_FILE=sfacctd.txt
readonly KAFKA_OUT_FILE=kafka.csv

# Assign default value if not value
function zz_var {
	eval "local readonly currval=\"\$$1\""
	if [ -z "${currval}" ]; then
		value="$(printf "%s" "$2" | sed 's%"%\\"%g')"
		eval "export $1=\"$value\""
	fi
}

#
# ZZ variables
#

zz_var KAFKA_BROKERS kafka
zz_var KAFKA_TOPIC flow
zz_var COLLECTOR_PORT 6343
zz_var SFACCTD_RENORMALIZE true
zz_var AGGREGATE 'cos, etype, src_mac, dst_mac, vlan, src_host, dst_host, src_mask, \
	dst_mask, src_net, dst_net, proto, tos, src_port, dst_port, tcpflags, \
	src_as, dst_as, as_path, src_as_path, src_host_country, \
	dst_host_country, in_iface, out_iface, sampling_rate, \
	export_proto_version, timestamp_arrival'

envsubst < ${OUT_FILE}.env > ${OUT_FILE}

#
# All RDKAFKA_ vars will be passed to librdkafka as-is
#

# Override librdkafka defaults
zz_var RDKAFKA_GLOBAL_SOCKET_KEEPALIVE_ENABLE true
zz_var RDKAFKA_GLOBAL_MESSAGE_SEND_MAX_RETRIES 0

# Read all librdkafka envs, chop first RDKAFKA, and change '_' for ','
env | sed -n '/^RDKAFKA_/s/RDKAFKA_//p;' | tr 'A-Z_' 'a-z.' | \
while IFS='=' read rdkafka_key rdkafka_val; do
	printf "%s,%s\n" "${rdkafka_key/./,}" "$rdkafka_val" >> ${KAFKA_OUT_FILE}
done

exec /app/sfacctd -f /app/sfacctd.txt
