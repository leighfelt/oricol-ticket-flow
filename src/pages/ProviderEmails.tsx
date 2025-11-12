import { useState, useEffect } from "react";
import { supabase } from "@/integrations/supabase/client";
import { useToast } from "@/hooks/use-toast";
import DashboardLayout from "@/components/DashboardLayout";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { 
  Table, 
  TableBody, 
  TableCell, 
  TableHead, 
  TableHeader, 
  TableRow 
} from "@/components/ui/table";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Mail, RefreshCw, Search, Eye, AlertCircle, CheckCircle, Clock } from "lucide-react";
import { format } from "date-fns";

interface ProviderEmail {
  id: string;
  created_at: string;
  updated_at: string;
  email_type: string;
  provider: string;
  subject: string;
  to_addresses: string[];
  cc_addresses: string[] | null;
  html_content: string;
  status: string;
  error_message: string | null;
  sent_at: string | null;
  resend_count: number;
  staff_member_name: string | null;
  staff_member_email: string | null;
  request_data: any;
  confirmation_token: string | null;
  confirmed_at: string | null;
  confirmed_by: string | null;
  provider_notes: string | null;
}

export default function ProviderEmails() {
  const { toast } = useToast();
  const [emails, setEmails] = useState<ProviderEmail[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedEmail, setSelectedEmail] = useState<ProviderEmail | null>(null);
  const [resending, setResending] = useState<string | null>(null);

  useEffect(() => {
    fetchEmails();
    
    // Set up real-time subscription
    const channel = supabase
      .channel('provider_emails_changes')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'provider_emails'
        },
        () => {
          fetchEmails();
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, []);

  const fetchEmails = async () => {
    setLoading(true);
    const { data, error } = await supabase
      .from("provider_emails")
      .select("*")
      .order("created_at", { ascending: false });

    if (error) {
      toast({
        title: "Error",
        description: "Failed to fetch email logs",
        variant: "destructive",
      });
    } else {
      setEmails(data || []);
    }
    setLoading(false);
  };

  const handleResend = async (emailId: string) => {
    setResending(emailId);
    
    try {
      const { error } = await supabase.functions.invoke('resend-provider-email', {
        body: { emailLogId: emailId }
      });

      if (error) throw error;

      toast({
        title: "Success",
        description: "Email resent successfully",
      });
      
      fetchEmails();
    } catch (error: any) {
      console.error("Error resending email:", error);
      toast({
        title: "Error",
        description: error.message || "Failed to resend email",
        variant: "destructive",
      });
    } finally {
      setResending(null);
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "sent":
        return <Badge className="bg-green-500"><CheckCircle className="h-3 w-3 mr-1" />Sent</Badge>;
      case "resent":
        return <Badge className="bg-blue-500"><RefreshCw className="h-3 w-3 mr-1" />Resent</Badge>;
      case "failed":
        return <Badge variant="destructive"><AlertCircle className="h-3 w-3 mr-1" />Failed</Badge>;
      case "pending":
        return <Badge variant="secondary"><Clock className="h-3 w-3 mr-1" />Pending</Badge>;
      default:
        return <Badge variant="outline">{status}</Badge>;
    }
  };

  const filteredEmails = emails.filter(email => 
    email.subject.toLowerCase().includes(searchTerm.toLowerCase()) ||
    email.staff_member_name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    email.provider.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const filterByStatus = (status?: string) => {
    if (!status) return filteredEmails;
    return filteredEmails.filter(email => email.status === status);
  };

  const stats = {
    total: emails.length,
    sent: emails.filter(e => e.status === "sent" || e.status === "resent").length,
    failed: emails.filter(e => e.status === "failed").length,
    pending: emails.filter(e => e.status === "pending").length,
  };

  const EmailTable = ({ emails }: { emails: ProviderEmail[] }) => (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>Date</TableHead>
          <TableHead>Provider</TableHead>
          <TableHead>Staff Member</TableHead>
          <TableHead>Subject</TableHead>
          <TableHead>Status</TableHead>
          <TableHead>Confirmed</TableHead>
          <TableHead>Resend Count</TableHead>
          <TableHead>Actions</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {emails.length === 0 ? (
          <TableRow>
            <TableCell colSpan={8} className="text-center text-muted-foreground">
              No emails found
            </TableCell>
          </TableRow>
        ) : (
          emails.map((email) => (
            <TableRow key={email.id}>
              <TableCell className="text-sm">
                {format(new Date(email.created_at), "MMM d, yyyy HH:mm")}
              </TableCell>
              <TableCell>
                <Badge variant="outline" className="capitalize">{email.provider}</Badge>
              </TableCell>
              <TableCell>
                <div className="flex flex-col">
                  <span className="font-medium">{email.staff_member_name || "N/A"}</span>
                  <span className="text-xs text-muted-foreground">{email.staff_member_email}</span>
                </div>
              </TableCell>
              <TableCell className="max-w-xs truncate">{email.subject}</TableCell>
              <TableCell>{getStatusBadge(email.status)}</TableCell>
              <TableCell>
                {email.confirmed_at ? (
                  <div className="flex flex-col">
                    <Badge className="bg-green-500 w-fit">
                      <CheckCircle className="h-3 w-3 mr-1" />
                      Yes
                    </Badge>
                    <span className="text-xs text-muted-foreground mt-1">
                      {format(new Date(email.confirmed_at), "MMM d, HH:mm")}
                    </span>
                  </div>
                ) : (
                  <Badge variant="outline">Pending</Badge>
                )}
              </TableCell>
              <TableCell className="text-center">{email.resend_count}</TableCell>
              <TableCell>
                <div className="flex gap-2">
                  <Button
                    size="sm"
                    variant="outline"
                    onClick={() => setSelectedEmail(email)}
                  >
                    <Eye className="h-3 w-3 mr-1" />
                    View
                  </Button>
                  {(email.status === "failed" || email.status === "pending") && (
                    <Button
                      size="sm"
                      variant="outline"
                      onClick={() => handleResend(email.id)}
                      disabled={resending === email.id}
                    >
                      {resending === email.id ? (
                        <RefreshCw className="h-3 w-3 mr-1 animate-spin" />
                      ) : (
                        <RefreshCw className="h-3 w-3 mr-1" />
                      )}
                      Resend
                    </Button>
                  )}
                </div>
              </TableCell>
            </TableRow>
          ))
        )}
      </TableBody>
    </Table>
  );

  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold">Provider Email Logs</h1>
          <p className="text-muted-foreground">Track and manage emails sent to external providers</p>
        </div>

        {/* Stats Cards */}
        <div className="grid gap-4 md:grid-cols-4">
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">Total Emails</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats.total}</div>
            </CardContent>
          </Card>
          
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">Sent</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-green-600">{stats.sent}</div>
            </CardContent>
          </Card>
          
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">Failed</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-red-600">{stats.failed}</div>
            </CardContent>
          </Card>
          
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">Pending</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-yellow-600">{stats.pending}</div>
            </CardContent>
          </Card>
        </div>

        {/* Search */}
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <div>
                <CardTitle>Email Logs</CardTitle>
                <CardDescription>View and manage all provider communication</CardDescription>
              </div>
              <Button onClick={fetchEmails} variant="outline" size="sm">
                <RefreshCw className="h-4 w-4 mr-2" />
                Refresh
              </Button>
            </div>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="relative">
              <Search className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search by staff name, provider, or subject..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-9"
              />
            </div>

            <Tabs defaultValue="all">
              <TabsList>
                <TabsTrigger value="all">
                  All ({filteredEmails.length})
                </TabsTrigger>
                <TabsTrigger value="sent">
                  Sent ({filterByStatus("sent").length + filterByStatus("resent").length})
                </TabsTrigger>
                <TabsTrigger value="failed">
                  Failed ({filterByStatus("failed").length})
                </TabsTrigger>
                <TabsTrigger value="pending">
                  Pending ({filterByStatus("pending").length})
                </TabsTrigger>
              </TabsList>

              <TabsContent value="all">
                <EmailTable emails={filteredEmails} />
              </TabsContent>

              <TabsContent value="sent">
                <EmailTable emails={[...filterByStatus("sent"), ...filterByStatus("resent")]} />
              </TabsContent>

              <TabsContent value="failed">
                <EmailTable emails={filterByStatus("failed")} />
              </TabsContent>

              <TabsContent value="pending">
                <EmailTable emails={filterByStatus("pending")} />
              </TabsContent>
            </Tabs>
          </CardContent>
        </Card>
      </div>

      {/* Email Details Dialog */}
      <Dialog open={!!selectedEmail} onOpenChange={() => setSelectedEmail(null)}>
        <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Email Details</DialogTitle>
            <DialogDescription>
              {selectedEmail && format(new Date(selectedEmail.created_at), "PPpp")}
            </DialogDescription>
          </DialogHeader>

          {selectedEmail && (
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <h4 className="text-sm font-semibold mb-1">Provider</h4>
                  <Badge variant="outline" className="capitalize">{selectedEmail.provider}</Badge>
                </div>
                <div>
                  <h4 className="text-sm font-semibold mb-1">Status</h4>
                  {getStatusBadge(selectedEmail.status)}
                </div>
                <div>
                  <h4 className="text-sm font-semibold mb-1">Staff Member</h4>
                  <p className="text-sm">{selectedEmail.staff_member_name || "N/A"}</p>
                  <p className="text-xs text-muted-foreground">{selectedEmail.staff_member_email}</p>
                </div>
                <div>
                  <h4 className="text-sm font-semibold mb-1">Resend Count</h4>
                  <p className="text-sm">{selectedEmail.resend_count}</p>
                </div>
              </div>

              <div>
                <h4 className="text-sm font-semibold mb-1">Subject</h4>
                <p className="text-sm">{selectedEmail.subject}</p>
              </div>

              <div>
                <h4 className="text-sm font-semibold mb-1">To</h4>
                <div className="flex flex-wrap gap-1">
                  {selectedEmail.to_addresses.map((addr, i) => (
                    <Badge key={i} variant="secondary">{addr}</Badge>
                  ))}
                </div>
              </div>

              {selectedEmail.cc_addresses && selectedEmail.cc_addresses.length > 0 && (
                <div>
                  <h4 className="text-sm font-semibold mb-1">CC</h4>
                  <div className="flex flex-wrap gap-1">
                    {selectedEmail.cc_addresses.map((addr, i) => (
                      <Badge key={i} variant="outline">{addr}</Badge>
                    ))}
                  </div>
                </div>
              )}

              {selectedEmail.error_message && (
                <div>
                  <h4 className="text-sm font-semibold mb-1 text-destructive">Error Message</h4>
                  <p className="text-sm bg-destructive/10 p-3 rounded">{selectedEmail.error_message}</p>
                </div>
              )}

              {selectedEmail.confirmed_at && (
                <div className="bg-green-50 border border-green-200 rounded p-4">
                  <h4 className="text-sm font-semibold mb-2 text-green-800 flex items-center gap-2">
                    <CheckCircle className="h-4 w-4" />
                    Task Confirmed
                  </h4>
                  <div className="grid grid-cols-2 gap-2 text-sm">
                    <div>
                      <span className="text-green-700">Confirmed At:</span>
                      <p className="font-medium">{format(new Date(selectedEmail.confirmed_at), "PPpp")}</p>
                    </div>
                    {selectedEmail.confirmed_by && (
                      <div>
                        <span className="text-green-700">Confirmed By:</span>
                        <p className="font-medium">{selectedEmail.confirmed_by}</p>
                      </div>
                    )}
                  </div>
                  {selectedEmail.provider_notes && (
                    <div className="mt-2">
                      <span className="text-green-700">Provider Notes:</span>
                      <p className="text-sm mt-1">{selectedEmail.provider_notes}</p>
                    </div>
                  )}
                </div>
              )}

              <div>
                <h4 className="text-sm font-semibold mb-2">Email Content</h4>
                <div 
                  className="border rounded p-4 bg-muted/50 text-sm overflow-auto max-h-96"
                  dangerouslySetInnerHTML={{ __html: selectedEmail.html_content }}
                />
              </div>

              <div className="flex gap-2">
                <Button onClick={() => setSelectedEmail(null)} variant="outline">
                  Close
                </Button>
                {(selectedEmail.status === "failed" || selectedEmail.status === "pending") && (
                  <Button
                    onClick={() => {
                      handleResend(selectedEmail.id);
                      setSelectedEmail(null);
                    }}
                    disabled={resending === selectedEmail.id}
                  >
                    <RefreshCw className="h-4 w-4 mr-2" />
                    Resend Email
                  </Button>
                )}
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </DashboardLayout>
  );
}
