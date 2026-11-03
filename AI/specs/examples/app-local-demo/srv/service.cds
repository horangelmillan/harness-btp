using { app.local.demo as db } from '../db/schema';

@(requires: 'Viewer')
service CatalogService {
  entity Books as projection on db.Books;
}
