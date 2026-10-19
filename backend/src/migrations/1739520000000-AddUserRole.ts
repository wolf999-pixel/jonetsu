import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddUserRole1739520000000 implements MigrationInterface {
  name = 'AddUserRole1739520000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TABLE "users"
      ADD COLUMN IF NOT EXISTS "role" varchar(20) NOT NULL DEFAULT 'user';
    `);

    await queryRunner.query(`
      UPDATE "users"
      SET "role" = 'user'
      WHERE "role" IS NULL OR "role" = '';
    `);

    await queryRunner.query(`
      CREATE INDEX IF NOT EXISTS "IDX_users_role"
      ON "users" ("role");
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      DROP INDEX IF EXISTS "IDX_users_role";
    `);

    await queryRunner.query(`
      ALTER TABLE "users"
      DROP COLUMN IF EXISTS "role";
    `);
  }
}
