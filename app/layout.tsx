import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "QuickBite - Smart Food Ordering Platform",
  description: "Compare prices across Swiggy, Zomato, and ONDC. Get the best deals on food delivery.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="antialiased">
        {children}
      </body>
    </html>
  );
}
