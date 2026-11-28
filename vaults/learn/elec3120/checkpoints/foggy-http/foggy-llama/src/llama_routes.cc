#include "foggy_llama.h"

int foggy_llama_register_routes(foggy_http_server_t *server, foggy_llama_service_t *service) {
    if (foggy_http_server_get(server, "/health", foggy_llama_health, service) < 0)
        return -1;
    if (foggy_http_server_get(server, "/v1/models", foggy_llama_models, service) < 0)
        return -1;
    if (foggy_http_server_post(server, "/v1/chat/completions", foggy_llama_chat, service) < 0)
        return -1;
    return 0;
}
