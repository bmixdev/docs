#!/bin/sh
# Конфигурация Jira
JIRA_URL="https://your_jira_instance.atlassian.net"
USERNAME="your_username"
API_TOKEN="your_api_token"

# Функция для получения информации о задаче
get_issue_info() {
    ISSUE_KEY="$1"
    echo "Получение информации о задаче ${ISSUE_KEY}..."
    curl -s -u "${USERNAME}:${API_TOKEN}" \
         -X GET \
         -H "Content-Type: application/json" \
         "${JIRA_URL}/rest/api/2/issue/${ISSUE_KEY}"
}

# Функция для получения информации о релизе (версии)
get_release_info() {
    VERSION_ID="$1"
    echo "Получение информации о релизе с идентификатором ${VERSION_ID}..."
    curl -s -u "${USERNAME}:${API_TOKEN}" \
         -X GET \
         -H "Content-Type: application/json" \
         "${JIRA_URL}/rest/api/2/version/${VERSION_ID}"
}

# Функция для получения списка задач, включенных в релиз (по fixVersion)
get_issues_in_release() {
    VERSION_ID="$1"
    echo "Получение задач, привязанных к релизу ${VERSION_ID}..."
    # Используется JQL для поиска задач с указанной fixVersion
    curl -s -u "${USERNAME}:${API_TOKEN}" \
         -X GET \
         -H "Content-Type: application/json" \
         "${JIRA_URL}/rest/api/2/search?jql=fixVersion=${VERSION_ID}"
}

# Функция для смены статуса задачи (перехода)
change_issue_status() {
    ISSUE_KEY="$1"
    TRANSITION_ID="$2"
    echo "Изменение статуса задачи ${ISSUE_KEY} через переход ${TRANSITION_ID}..."
    curl -s -u "${USERNAME}:${API_TOKEN}" \
         -X POST \
         -H "Content-Type: application/json" \
         --data "{\"transition\": {\"id\": \"${TRANSITION_ID}\"}}" \
         "${JIRA_URL}/rest/api/2/issue/${ISSUE_KEY}/transitions"
}

# Функция для добавления комментария к задаче
add_comment() {
    ISSUE_KEY="$1"
    COMMENT="$2"
    echo "Добавление комментария к задаче ${ISSUE_KEY}..."
    curl -s -u "${USERNAME}:${API_TOKEN}" \
         -X POST \
         -H "Content-Type: application/json" \
         --data "{\"body\": \"${COMMENT}\"}" \
         "${JIRA_URL}/rest/api/2/issue/${ISSUE_KEY}/comment"
}

# Функция вывода справки
show_help() {
    echo "Использование: $0 {get-issue|get-release|get-release-issues|change-status|add-comment} [параметры]"
    echo "  get-issue ISSUE_KEY            - Получить информацию о задаче"
    echo "  get-release VERSION_ID         - Получить информацию о релизе (версии)"
    echo "  get-release-issues VERSION_ID    - Получить список задач с fixVersion = VERSION_ID"
    echo "  change-status ISSUE_KEY TRANSITION_ID  - Изменить статус задачи"
    echo "  add-comment ISSUE_KEY \"COMMENT\"         - Добавить комментарий к задаче"
}

# Проверка параметров командной строки
if [ $# -lt 2 ]; then
    show_help
    exit 1
fi

COMMAND="$1"
shift

case "$COMMAND" in
    get-issue)
        get_issue_info "$1"
        ;;
    get-release)
        get_release_info "$1"
        ;;
    get-release-issues)
        get_issues_in_release "$1"
        ;;
    change-status)
        if [ $# -ne 2 ]; then
            show_help
            exit 1
        fi
        change_issue_status "$1" "$2"
        ;;
    add-comment)
        if [ $# -lt 2 ]; then
            show_help
            exit 1
        fi
        ISSUE_KEY="$1"
        shift
        COMMENT="$*"
        add_comment "$ISSUE_KEY" "$COMMENT"
        ;;
    *)
        show_help
        exit 1
        ;;
esac
