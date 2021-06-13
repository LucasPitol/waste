import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { routing } from './app.router';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { MatIconModule, MatButtonModule, MatProgressSpinnerModule, MatDialogModule, MatFormFieldModule, MatInputModule, MatListModule } from '@angular/material';
import { UserService } from './services/user-service';
import { ConfirmDialogComponent } from './pages/subpages/confirm-dialog/confirm-dialog.component';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { AlertDialogComponent } from './pages/subpages/alert-dialog/alert-dialog.component';
import { LoginComponent } from './pages/login/login.component';
import { PaymentComponent } from './pages/payment/payment.component';


@NgModule({
  declarations: [
    AppComponent,
    AlertDialogComponent,
    ConfirmDialogComponent,
    LoginComponent,
    PaymentComponent,
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
    AlertDialogComponent,
    ConfirmDialogComponent,
  ]
})
export class AppModule { }
