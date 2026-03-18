import mysql.connector
from mysql.connector import Error
from src.common.config import DB_CONFIG
from src.common.helpers import print_menu


# =========================
# CONNEXION
# =========================
def get_connection():
    return mysql.connector.connect(**DB_CONFIG)


# =========================
# READ
# =========================
def list_clients():
    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute(
            "SELECT id_client, nom, prenom, email FROM client ORDER BY id_client"
        )

        print("\n--- Liste des clients ---")
        for row in cursor.fetchall():
            print(row)

    except Error as e:
        print(f"❌ Erreur MySQL : {e}")

    finally:
        if cursor:
            cursor.close()
        if conn and conn.is_connected():
            conn.close()


# =========================
# CREATE
# =========================
def create_client(nom, prenom, email):
    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute(
            "INSERT INTO client (nom, prenom, email) VALUES (%s, %s, %s)",
            (nom, prenom, email),
        )

        conn.commit()
        print("✅ Client ajouté !")

    except Error as e:
        if conn:
            conn.rollback()
        print(f"❌ Erreur MySQL : {e}")

    finally:
        if cursor:
            cursor.close()
        if conn and conn.is_connected():
            conn.close()


# =========================
# UPDATE
# =========================
def update_client(id_client, nom, prenom, email):
    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute(
            """
            UPDATE client
            SET nom = %s, prenom = %s, email = %s
            WHERE id_client = %s
            """,
            (nom, prenom, email, id_client),
        )

        conn.commit()

        if cursor.rowcount > 0:
            print("✅ Client modifié !")
        else:
            print("⚠️ Aucun client trouvé")

    except Error as e:
        if conn:
            conn.rollback()
        print(f"❌ Erreur MySQL : {e}")

    finally:
        if cursor:
            cursor.close()
        if conn and conn.is_connected():
            conn.close()


# =========================
# DELETE
# =========================
def delete_client(id_client):
    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute(
            "DELETE FROM client WHERE id_client = %s",
            (id_client,),
        )

        conn.commit()

        if cursor.rowcount > 0:
            print("🗑️ Client supprimé !")
        else:
            print("⚠️ Aucun client trouvé")

    except Error as e:
        if conn:
            conn.rollback()
        print(f"❌ Erreur MySQL : {e}")

    finally:
        if cursor:
            cursor.close()
        if conn and conn.is_connected():
            conn.close()


# =========================
# MENU
# =========================
def main():
    while True:
        print_menu("Mode DB-API")

        print("1. Lister les clients")
        print("2. Ajouter un client")
        print("3. Modifier un client")
        print("4. Supprimer un client")
        print("0. Quitter")

        choix = input("\nChoix : ")

        if choix == "1":
            list_clients()

        elif choix == "2":
            nom = input("Nom : ")
            prenom = input("Prénom : ")
            email = input("Email : ")
            create_client(nom, prenom, email)

        elif choix == "3":
            try:
                id_client = int(input("ID du client : "))
                nom = input("Nom : ")
                prenom = input("Prénom : ")
                email = input("Email : ")
                update_client(id_client, nom, prenom, email)
            except ValueError:
                print("❌ ID invalide")

        elif choix == "4":
            try:
                id_client = int(input("ID du client : "))
                delete_client(id_client)
            except ValueError:
                print("❌ ID invalide")

        elif choix == "0":
            print("👋 Au revoir !")
            break

        else:
            print("❌ Choix invalide")


if __name__ == "__main__":
    main()
