export interface Coach {
  id: string;
  name: string;
  specialty: string;
  rating: number;
  reviews: number;
  price: number;
  image: string;
  latitude: number;
  longitude: number;
  description: string;
  isAvailable?: boolean;
}