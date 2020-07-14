import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { routing } from './app.router';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { DeleteUserComponent } from './pages/delete-user/delete-user.component';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { MatIconModule, MatButtonModule, MatProgressSpinnerModule, MatDialogModule, MatFormFieldModule, MatInputModule } from '@angular/material';
import { HomeComponent } from './pages/home/home.component';
import { UserService } from './services/user-service';
import { ConfirmDialogComponent } from './pages/subpages/confirm-dialog/confirm-dialog.component';
import { ChangePasswordComponent } from './pages/change-password/change-password.component';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';


@NgModule({
  declarations: [
    AppComponent,
    DeleteUserComponent,
    HomeComponent,
    ConfirmDialogComponent,
    ChangePasswordComponent,
  ],
  imports: [
    routing,
    BrowserModule,
    AppRoutingModule,
    BrowserAnimationsModule,
    MatButtonModule,
    MatIconModule,
    MatProgressSpinnerModule,
    MatDialogModule,
    MatFormFieldModule,
    FormsModule,
    MatInputModule,
    ReactiveFormsModule,
  ],
  providers: [
    UserService,
  ],
  bootstrap: [AppComponent],
  entryComponents: [
    ConfirmDialogComponent,
  ]
})
export class AppModule { }
