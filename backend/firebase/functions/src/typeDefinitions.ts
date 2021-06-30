// State of fine payment
export interface PayedState {

    // State of the payment of the fine
    state: "payed" | "settled" | "unpayed";

    // Pay date of the fine (provided if state is `payed`)
    payDate?: number;

    // Indicates if the fine is payed in app (provided if state is `payed`)
    inApp?: boolean;
}

// Fine reason with template id
export interface FineReasonTemplate {

    // Id of template associated with fine reason
    templateId: string;
}

// Fine reason with reason message, amount and importance
export interface FineReasonCustom {

    // Reason message of the fine
    reason: string;

    // Amount of the fine
    amount: number;

    // Importance of the fine
    importance: "low" | "medium" | "high";
}

// First and last name of a person
export interface PersonName {

    // First name
    first: string;

    // Last name (can be null)
    last: string | null;
}

// Contains all properties of a person
export interface Person {

    // Id of the person
    id: string;

    // Name of the person
    name: PersonName;
}

export interface PersonProperties {

    // Name of the person
    name: PersonName;

    signInData?: {
        cashier: boolean;
        userId: string;
        signInDate: number;
    }
}

// Contains all porperties of a fine in statistics
export interface Fine {

    // Id of the fine
    id: string;

    // Id of associated person of the fine
    personId: string;

    // State of payement
    payed: PayedState;

    // Number of fines
    number: number;

    // Date when fine was created
    date: number;

    // Reason of fine
    reason: FineReasonTemplate | FineReasonCustom;
}

// Contains all properties of a fine in statistics
export interface StatisticsFine {

    // Id of the fine
    id: string;

    // Associated person of the fine
    person: Person;

    // State of payement
    payed: PayedState;

    // Number of fines
    number: number;

    // Date when fine was created
    date: number;

    // Reason of fine
    reason: StatisticsFineReason;
}

// Contains all properties of a fine reason in staistics
export interface StatisticsFineReason {

    // Id of template reason, null if fine reason is custom
    id?: string;

    // Reason message of the fine
    reason: string;

    // Amount of the fine
    amount: number;

    // Importance of the fine (`low`, `medium`, `high`)
    importance: "low" | "medium" | "high";
}

// Period of a time
export interface TimePeriod {

    // Value of the time period
    value: number;

    // Unit of the time period
    unit: "day" | "month" | "year";
}

// Late payement interest
export interface LatePaymentInterest {

    // Interest free timeinterval
    interestFreePeriod: TimePeriod;

    // Interest timeinterval
    interestPeriod: TimePeriod;

    // Rate of the interest
    interestRate: number;

    // Indicates whether compound interest is active
    compoundInterest: boolean;
}

export interface ClubProperties {
    identifier: string;
    name: string;
    regionCode: string;
    inAppPaymentActive: boolean;
    persons: {
        [key: string]: PersonProperties;
    };
    personUserIds: {
        [key: string]: string;
    };
}
