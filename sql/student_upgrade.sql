-- ============================================================
--  BoutikPro — Schéma initial MySQL
--  Fichier : sql/schema.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS boutikpro
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE boutikpro;

-- ── Catégories produit ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS categorie_produit (
    id_categorie_produit INT AUTO_INCREMENT PRIMARY KEY,
    libelle              VARCHAR(100) NOT NULL,
    description          TEXT
);

-- ── Catégories fournisseur ───────────────────────────────────
CREATE TABLE IF NOT EXISTS categorie_fournisseur (
    id_categorie_fournisseur INT AUTO_INCREMENT PRIMARY KEY,
    libelle                  VARCHAR(100) NOT NULL
);

-- ── Fournisseurs ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS fournisseur (
    id_fournisseur           INT AUTO_INCREMENT PRIMARY KEY,
    nom                      VARCHAR(150) NOT NULL,
    email                    VARCHAR(150),
    adresse                  TEXT,
    id_categorie_fournisseur INT,
    CONSTRAINT fk_fourn_cat FOREIGN KEY (id_categorie_fournisseur)
        REFERENCES categorie_fournisseur(id_categorie_fournisseur)
        ON DELETE SET NULL
);

-- ── Produits ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS produit (
    id_produit           INT AUTO_INCREMENT PRIMARY KEY,
    reference            VARCHAR(50)    NOT NULL UNIQUE,
    designation          VARCHAR(200)   NOT NULL,
    prix_vente           DECIMAL(10,2)  NOT NULL CHECK (prix_vente >= 0),
    id_categorie_produit INT,
    CONSTRAINT fk_prod_cat FOREIGN KEY (id_categorie_produit)
        REFERENCES categorie_produit(id_categorie_produit)
        ON DELETE SET NULL
);

-- ── Livraison (Produit ↔ Fournisseur N,N) ────────────────────
CREATE TABLE IF NOT EXISTS livraison (
    id_produit     INT            NOT NULL,
    id_fournisseur INT            NOT NULL,
    prix_achat     DECIMAL(10,2),
    delai_jours    SMALLINT UNSIGNED,
    PRIMARY KEY (id_produit, id_fournisseur),
    CONSTRAINT fk_liv_prod FOREIGN KEY (id_produit)
        REFERENCES produit(id_produit) ON DELETE CASCADE,
    CONSTRAINT fk_liv_fourn FOREIGN KEY (id_fournisseur)
        REFERENCES fournisseur(id_fournisseur) ON DELETE CASCADE
);

-- ── Clients ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS client (
    id_client       INT AUTO_INCREMENT PRIMARY KEY,
    nom             VARCHAR(100) NOT NULL,
    prenom          VARCHAR(100),
    email           VARCHAR(150) UNIQUE,
    adresse         TEXT,
    date_inscription DATE DEFAULT (CURRENT_DATE),
    id_parrain      INT NULL,
    CONSTRAINT fk_client_parrain FOREIGN KEY (id_parrain)
        REFERENCES client(id_client) ON DELETE SET NULL
);

-- ── Carte fidélité ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS carte_fidelite (
    id_carte       INT AUTO_INCREMENT PRIMARY KEY,
    id_client      INT NOT NULL UNIQUE,
    points_cumules INT DEFAULT 0 CHECK (points_cumules >= 0),
    date_creation  DATE DEFAULT (CURRENT_DATE),
    statut         ENUM('active','suspendue','expiree') DEFAULT 'active',
    CONSTRAINT fk_carte_client FOREIGN KEY (id_client)
        REFERENCES client(id_client) ON DELETE CASCADE
);

-- ── Commandes ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS commande (
    id_commande   INT AUTO_INCREMENT PRIMARY KEY,
    id_client     INT           NOT NULL,
    date_commande DATETIME      DEFAULT CURRENT_TIMESTAMP,
    statut        ENUM('brouillon','validee','facturee') DEFAULT 'brouillon',
    montant_total DECIMAL(10,2) DEFAULT 0.00,
    CONSTRAINT fk_cmd_client FOREIGN KEY (id_client)
        REFERENCES client(id_client) ON DELETE RESTRICT
);

-- ── Lignes de commande (Commande ↔ Produit N,N) ──────────────
CREATE TABLE IF NOT EXISTS ligne_commande (
    id_commande   INT           NOT NULL,
    id_produit    INT           NOT NULL,
    quantite      INT           NOT NULL CHECK (quantite > 0),
    prix_unitaire DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_commande, id_produit),
    CONSTRAINT fk_lc_cmd  FOREIGN KEY (id_commande)
        REFERENCES commande(id_commande) ON DELETE CASCADE,
    CONSTRAINT fk_lc_prod FOREIGN KEY (id_produit)
        REFERENCES produit(id_produit) ON DELETE RESTRICT
);

-- ── Factures ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS facture (
    id_facture    INT AUTO_INCREMENT PRIMARY KEY,
    id_commande   INT           NOT NULL UNIQUE,   -- 1 facture / commande
    date_facture  DATE          DEFAULT (CURRENT_DATE),
    montant_ht    DECIMAL(10,2) NOT NULL,
    tva           DECIMAL(5,2)  DEFAULT 20.00,
    montant_ttc   DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_fact_cmd FOREIGN KEY (id_commande)
        REFERENCES commande(id_commande) ON DELETE RESTRICT
);
